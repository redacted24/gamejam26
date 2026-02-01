extends State

@export var enemy: CharacterBody2D

enum Phase { STALKING, PREDICTING, DASHING, RECOVERING, DODGING }

var phase: int = Phase.STALKING
var timer: float = 0.0
var strafe_dir: float = 1.0  # 1.0 = clockwise, -1.0 = counter-clockwise
var dash_dir: Vector2 = Vector2.ZERO
var predicted_pos: Vector2 = Vector2.ZERO
var has_hit: bool = false

# Knockback
var knockback_velocity: Vector2 = Vector2.ZERO

# Dodge state
var dodge_dir: Vector2 = Vector2.ZERO
var dodge_cooldown: float = 0.0
var phase_before_dodge: int = Phase.STALKING
var timer_before_dodge: float = 0.0

# Stalking parameters
const STALK_DURATION_MIN := 1.2
const STALK_DURATION_MAX := 2.0
const PREFERRED_DIST_MIN := 100.0
const PREFERRED_DIST_MAX := 150.0
const STRAFE_SPEED_MULT := 1.0
const APPROACH_SPEED_MULT := 0.7
const RETREAT_SPEED_MULT := 0.9
const REPOSITION_CHANCE := 0.03  # Per-frame chance to flip strafe direction

# Prediction / dash parameters
const PREDICT_TIME := 0.5
const DASH_TIME := 0.4
const RECOVERY_TIME_MIN := 0.4
const RECOVERY_TIME_MAX := 0.6
const DASH_OVERSHOOT := 80.0  # Extra distance past the predicted point

# Dodge parameters
const DODGE_SPEED := 550.0
const DODGE_TIME := 0.15
const DODGE_COOLDOWN := 0.8

func enter() -> void:
	phase = Phase.STALKING
	timer = randf_range(STALK_DURATION_MIN, STALK_DURATION_MAX)
	strafe_dir = 1.0 if randf() > 0.5 else -1.0
	knockback_velocity = Vector2.ZERO
	has_hit = false
	dodge_cooldown = 0.0

func physics_process(delta: float) -> void:
	var player: Node2D = enemy.get_player()
	if not player:
		enemy.velocity = Vector2.ZERO
		enemy.move_and_slide()
		return

	# Handle knockback
	if knockback_velocity.length() > 5:
		enemy.velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 6.0 * delta)
		enemy.move_and_slide()
		return

	if dodge_cooldown > 0:
		dodge_cooldown -= delta

	timer -= delta

	match phase:
		Phase.STALKING:
			if _try_dodge():
				return
			_do_stalking(delta, player)
		Phase.PREDICTING:
			_do_predicting(delta, player)
		Phase.DASHING:
			_do_dashing(delta, player)
		Phase.RECOVERING:
			if _try_dodge():
				return
			_do_recovering(delta)
		Phase.DODGING:
			_do_dodging(delta)

# ---- PROJECTILE DODGE ----
const DETECT_RADIUS := 140.0

func _try_dodge() -> bool:
	if dodge_cooldown > 0:
		return false
	# Direct physics query — bypasses monitorable=false on projectiles
	var space := enemy.get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = DETECT_RADIUS
	query.shape = shape
	query.transform = enemy.global_transform
	query.collision_mask = 8  # player_projectiles layer
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var results := space.intersect_shape(query, 8)
	for result in results:
		var collider = result["collider"]
		if not (collider is Projectile):
			continue
		var proj: Projectile = collider
		if not proj.is_player_projectile:
			continue
		# Check if projectile is heading roughly toward us
		var to_wolf: Vector2 = enemy.global_position - proj.global_position
		if proj.direction.dot(to_wolf.normalized()) < 0.3:
			continue  # Not headed our way
		# Dodge perpendicular to the projectile's travel direction
		var perp := Vector2(-proj.direction.y, proj.direction.x)
		# Pick the side that moves us away from the projectile's line of travel
		if perp.dot(to_wolf) < 0:
			perp = -perp
		_enter_dodge(perp.normalized())
		return true
	return false

func _enter_dodge(direction: Vector2) -> void:
	print("Wolf dodged!")
	phase_before_dodge = phase
	timer_before_dodge = timer
	phase = Phase.DODGING
	timer = DODGE_TIME
	dodge_dir = direction
	dodge_cooldown = DODGE_COOLDOWN

func _do_dodging(delta: float) -> void:
	enemy.velocity = dodge_dir * DODGE_SPEED
	enemy.move_and_slide()
	if timer <= 0:
		# Return to previous phase
		phase = phase_before_dodge
		timer = timer_before_dodge

# ---- STALKING: maintain distance, strafe laterally ----
func _do_stalking(delta: float, player: Node2D) -> void:
	var to_player: Vector2 = player.global_position - enemy.global_position
	var dist: float = to_player.length()
	var dir_to_player: Vector2 = to_player.normalized()

	# Strafe perpendicular to player direction
	var strafe_vec: Vector2 = Vector2(-dir_to_player.y, dir_to_player.x) * strafe_dir
	var move_vec: Vector2 = strafe_vec * STRAFE_SPEED_MULT

	# Approach or retreat to stay in preferred range
	if dist > PREFERRED_DIST_MAX:
		move_vec += dir_to_player * APPROACH_SPEED_MULT
	elif dist < PREFERRED_DIST_MIN:
		move_vec -= dir_to_player * RETREAT_SPEED_MULT

	# Occasional strafe direction flip for unpredictability
	if randf() < REPOSITION_CHANCE:
		strafe_dir *= -1.0

	enemy.velocity = move_vec.normalized() * enemy.speed
	enemy.move_and_slide()

	if timer <= 0:
		_enter_predicting(player)

# ---- PREDICTING: freeze, calculate intercept, wind-up visual ----
func _enter_predicting(player: Node2D) -> void:
	phase = Phase.PREDICTING
	timer = PREDICT_TIME
	enemy.velocity = Vector2.ZERO

	# Calculate predicted intercept position
	var player_vel: Vector2 = Vector2.ZERO
	if player is CharacterBody2D:
		player_vel = player.velocity
	var travel_time: float = PREDICT_TIME + DASH_TIME * 0.5
	predicted_pos = player.global_position + player_vel * travel_time

	# Compute dash direction with overshoot
	var to_target: Vector2 = predicted_pos - enemy.global_position
	dash_dir = to_target.normalized()
	# Push the target further so the wolf dashes past
	predicted_pos += dash_dir * DASH_OVERSHOOT

	# Attack sound at start of wind-up (0.5s before dash)
	var wolf := enemy as WolfEnemy
	if wolf and wolf.attack_sound:
		wolf.attack_sound.play()

	# Red tint wind-up cue
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		var tween := enemy.create_tween()
		tween.tween_property(visual, "modulate", Color(1.0, 0.4, 0.4), PREDICT_TIME)

func _do_predicting(_delta: float, _player: Node2D) -> void:
	enemy.velocity = Vector2.ZERO
	enemy.move_and_slide()

	if timer <= 0:
		phase = Phase.DASHING
		timer = DASH_TIME
		has_hit = false

# ---- DASHING: lunge through the predicted position ----
func _do_dashing(_delta: float, player: Node2D) -> void:
	var wolf := enemy as WolfEnemy
	enemy.velocity = dash_dir * wolf.dash_speed
	enemy.move_and_slide()

	# Proximity hit check (pass through, don't stop)
	if not has_hit:
		var dist: float = enemy.global_position.distance_to(player.global_position)
		if dist < 35 and player.has_method("take_damage"):
			player.take_damage(wolf.dash_damage, enemy.global_position)
			has_hit = true

	if timer <= 0:
		_enter_recovering()

# ---- RECOVERING: decelerate, vulnerability window ----
func _enter_recovering() -> void:
	phase = Phase.RECOVERING
	timer = randf_range(RECOVERY_TIME_MIN, RECOVERY_TIME_MAX)
	# Reset tint
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		var tween := enemy.create_tween()
		tween.tween_property(visual, "modulate", Color.WHITE, 0.2)

func _do_recovering(delta: float) -> void:
	enemy.velocity = enemy.velocity.lerp(Vector2.ZERO, 5.0 * delta)
	enemy.move_and_slide()

	if timer <= 0:
		phase = Phase.STALKING
		timer = randf_range(STALK_DURATION_MIN, STALK_DURATION_MAX)
		strafe_dir = 1.0 if randf() > 0.5 else -1.0

func apply_knockback(direction: Vector2, force: float) -> void:
	knockback_velocity = direction * force
	if phase == Phase.DASHING:
		_enter_recovering()
