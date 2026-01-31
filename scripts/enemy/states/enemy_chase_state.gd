extends State
class_name EnemyChaseState

@export var enemy: CharacterBody2D
@export var turn_speed: float = 20.0

# Rat scurry behavior
var scurry_timer: float = 0.0
var is_moving: bool = true
var current_speed: float = 0.0
var current_dir: Vector2 = Vector2.ZERO
var zigzag_side: float = 1.0

# Lunge attack
var is_lunging: bool = false
var lunge_timer: float = 0.0
var is_retreating: bool = false
var retreat_timer: float = 0.0
var attack_cooldown: float = 0.0

# Knockback
var knockback_velocity: Vector2 = Vector2.ZERO

func enter() -> void:
	scurry_timer = 0.0
	is_moving = true
	zigzag_side = 1.0
	is_lunging = false
	is_retreating = false
	attack_cooldown = 1.0

func physics_process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return

	# Handle knockback first
	if knockback_velocity.length() > 5:
		enemy.velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 6.0 * delta)
		enemy.move_and_slide()
		return

	var dist: float = enemy.global_position.distance_to(player.global_position)
	var to_player: Vector2 = (player.global_position - enemy.global_position).normalized()

	attack_cooldown -= delta

	# Lunge attack
	if is_lunging:
		lunge_timer -= delta
		enemy.velocity = current_dir * current_speed
		enemy.move_and_slide()
		# Deal damage on contact during lunge
		if dist < 25 and player.has_method("take_damage"):
			player.take_damage(enemy.contact_damage, enemy.global_position)
			is_lunging = false
			_start_retreat(to_player)
		elif lunge_timer <= 0:
			is_lunging = false
			_start_retreat(to_player)
		_update_visual(delta)
		return

	# Retreat after lunge
	if is_retreating:
		retreat_timer -= delta
		enemy.velocity = current_dir * current_speed
		enemy.move_and_slide()
		if retreat_timer <= 0:
			is_retreating = false
			scurry_timer = 0.0
		_update_visual(delta)
		return

	# Start lunge attack when close enough and cooldown ready
	if dist < 60 and attack_cooldown <= 0:
		_start_lunge(to_player)
		_update_visual(delta)
		return

	# Normal scurry behavior
	scurry_timer -= delta
	if scurry_timer <= 0:
		_new_scurry_cycle(player)

	if is_moving:
		enemy.velocity = current_dir * current_speed
	else:
		enemy.velocity = Vector2.ZERO

	enemy.move_and_slide()
	_update_visual(delta)

func _start_lunge(to_player: Vector2) -> void:
	is_lunging = true
	is_moving = false
	current_dir = to_player
	current_speed = enemy.speed * 4.0
	lunge_timer = 0.15

	# Visual feedback - squash forward
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		var tween := enemy.create_tween()
		tween.tween_property(visual, "modulate", Color(1.2, 0.8, 0.8), 0.05)

func _start_retreat(to_player: Vector2) -> void:
	is_retreating = true
	current_dir = -to_player
	current_speed = enemy.speed * 2.5
	retreat_timer = 0.2
	attack_cooldown = randf_range(0.8, 1.5)

	# Reset visual
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		var tween := enemy.create_tween()
		tween.tween_property(visual, "modulate", Color.WHITE, 0.1)

func _update_visual(delta: float) -> void:
	if current_dir.length() > 0.1:
		var visual := enemy.get_node("AnimatedSprite2D")
		visual.rotation = lerp_angle(visual.rotation, current_dir.angle(), turn_speed * delta)

func _new_scurry_cycle(player: Node2D) -> void:
	var to_player: Vector2 = (player.global_position - enemy.global_position).normalized()

	var roll := randf()

	if roll < 0.2:
		# FREEZE - tiny pause
		is_moving = false
		scurry_timer = randf_range(0.02, 0.08)
	elif roll < 0.5:
		# DART - fast micro burst
		is_moving = true
		var random_angle := randf_range(-PI/4, PI/4)
		current_dir = to_player.rotated(random_angle)
		current_speed = enemy.speed * randf_range(1.8, 3.0)
		scurry_timer = randf_range(0.02, 0.06)
	elif roll < 0.7:
		# ZIGZAG - quick sidestep
		is_moving = true
		zigzag_side *= -1.0
		var perpendicular := Vector2(-to_player.y, to_player.x) * zigzag_side
		current_dir = (to_player + perpendicular * 0.8).normalized()
		current_speed = enemy.speed * randf_range(1.5, 2.5)
		scurry_timer = randf_range(0.03, 0.07)
	elif roll < 0.85:
		# LUNGE - straight at player
		is_moving = true
		current_dir = to_player
		current_speed = enemy.speed * randf_range(2.0, 3.0)
		scurry_timer = randf_range(0.04, 0.1)
	else:
		# TWITCH - tiny random movement
		is_moving = true
		var random_angle := randf_range(-PI/5, PI/5)
		current_dir = to_player.rotated(random_angle)
		current_speed = enemy.speed * randf_range(1.2, 2.0)
		scurry_timer = randf_range(0.01, 0.04)

func apply_knockback(direction: Vector2, force: float) -> void:
	knockback_velocity = direction * force
	is_moving = false
	is_lunging = false
	is_retreating = false
	scurry_timer = 0.3
