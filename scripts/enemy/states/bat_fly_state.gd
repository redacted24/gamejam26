extends State

@export var enemy: CharacterBody2D
@export var hover_distance: float = 250.0
@export var shoot_cooldown: float = 2.0
@export var projectile_count: int = 5
@export var spread_angle: float = 45.0
@export var projectile_speed: float = 180.0
@export var spiral_ring_count: int = 12
@export var spiral_speed: float = 120.0

var angle: float = 0.0
var hover_time: float = 0.0
var shoot_timer: float = 1.5
var is_shooting: bool = false
var shoot_anim_timer: float = 0.0
var echolocation_sound: AudioStreamPlayer
var spin_sound: AudioStreamPlayer

# Spiral state
var is_spiraling: bool = false
var spiral_timer: float = 0.0
var spiral_angle: float = 0.0
var spiral_shots_fired: int = 0

# Dodge
var dodge_velocity: Vector2 = Vector2.ZERO
var dodge_cooldown: float = 0.0
const DODGE_DETECT_RADIUS: float = 120.0
const DODGE_STRENGTH: float = 220.0
const DODGE_COOLDOWN_TIME: float = 1.2

# Knockback
var knockback_velocity: Vector2 = Vector2.ZERO

func enter() -> void:
	angle = randf() * TAU
	shoot_timer = randf_range(1.0, 2.0)
	is_shooting = false
	is_spiraling = false
	echolocation_sound = enemy.get_node_or_null("EcholocationSound")
	spin_sound = enemy.get_node_or_null("SpinSound")

func physics_process(delta: float) -> void:
	var player: Node2D = enemy.get_player()
	if not player:
		return

	# Handle knockback
	if knockback_velocity.length() > 5:
		enemy.velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 3.0 * delta)
		enemy.move_and_slide()
		return

	hover_time += delta
	dodge_cooldown -= delta
	dodge_velocity = dodge_velocity.lerp(Vector2.ZERO, 5.0 * delta)

	# Spiral attack - fires rings one at a time while hovering
	if is_spiraling:
		_do_hover(delta, player)
		spiral_timer -= delta
		if spiral_timer <= 0:
			_fire_spiral_ring()
			spiral_shots_fired += 1
			if spiral_shots_fired >= spiral_ring_count:
				is_spiraling = false
				_show_idle_anim()
				shoot_timer = randf_range(shoot_cooldown - 0.3, shoot_cooldown + 0.3)
			else:
				spiral_timer = 0.08
		enemy.move_and_slide()
		_update_visual(delta)
		return

	# Shooting animation pause (shotgun)
	if is_shooting:
		shoot_anim_timer -= delta
		enemy.velocity = enemy.velocity.lerp(Vector2.ZERO, 5.0 * delta)
		if shoot_anim_timer <= 0:
			is_shooting = false
			_fire_shotgun(player)
		enemy.move_and_slide()
		_update_visual(delta)
		return

	# Hover at distance from player
	_do_hover(delta, player)

	# Shoot timer
	shoot_timer -= delta
	if shoot_timer <= 0:
		if randf() < 0.5:
			_start_spiral()
		else:
			is_shooting = true
			shoot_anim_timer = 0.3
			_show_attack_anim()
			if echolocation_sound:
				echolocation_sound.play()
			shoot_timer = randf_range(shoot_cooldown - 0.3, shoot_cooldown + 0.3)

	enemy.move_and_slide()
	_update_visual(delta)

func _do_hover(delta: float, player: Node2D) -> void:
	angle += delta * 1.5

	var to_player := player.global_position - enemy.global_position
	var dir_to_player := to_player.normalized()

	# Orbit offset
	var orbit_offset := Vector2(cos(angle), sin(angle) * 0.5) * 60.0

	# Target position: hover_distance away from player + orbit
	var target_pos := player.global_position - dir_to_player * hover_distance + orbit_offset
	target_pos.y -= 40.0

	var move_dir := target_pos - enemy.global_position
	_check_dodge()
	enemy.velocity = enemy.velocity.lerp(move_dir * 2.5, 3.0 * delta) + dodge_velocity

# --- Shotgun attack ---

func _fire_shotgun(player: Node2D) -> void:
	var to_player := (player.global_position - enemy.global_position).normalized()
	var half_spread := deg_to_rad(spread_angle)
	var step: float = (half_spread * 2.0) / maxf(float(projectile_count - 1), 1.0)

	for i in projectile_count:
		var angle_offset: float = -half_spread + step * i
		var dir := to_player.rotated(angle_offset)
		_spawn_ring(dir, projectile_speed)

	_show_idle_anim()

# --- Spiral attack ---

func _start_spiral() -> void:
	is_spiraling = true
	spiral_timer = 0.0
	spiral_angle = 0.0
	spiral_shots_fired = 0
	_show_attack_anim()
	if spin_sound:
		spin_sound.play()

func _fire_spiral_ring() -> void:
	var dir := Vector2(cos(spiral_angle), sin(spiral_angle))
	_spawn_ring(dir, spiral_speed)
	spiral_angle += TAU / float(spiral_ring_count) + 0.3  # offset creates spiral pattern

# --- Dodge ---

func _check_dodge() -> void:
	if dodge_cooldown > 0:
		return
	var projectiles := enemy.get_tree().get_nodes_in_group("player_projectiles")
	if projectiles.is_empty():
		# Fallback: scan all Projectile nodes
		for node: Node in enemy.get_tree().current_scene.get_children():
			if node is Projectile and node.is_player_projectile:
				var dist := enemy.global_position.distance_to(node.global_position)
				if dist < DODGE_DETECT_RADIUS:
					_do_dodge(node)
					return
	else:
		for node: Node in projectiles:
			if node is Projectile:
				var dist := enemy.global_position.distance_to(node.global_position)
				if dist < DODGE_DETECT_RADIUS:
					_do_dodge(node)
					return

func _do_dodge(proj: Projectile) -> void:
	# Dodge perpendicular to the projectile's direction
	var perp := Vector2(-proj.direction.y, proj.direction.x)
	# Pick the side that moves away from the projectile
	var to_bat := (enemy.global_position - proj.global_position).normalized()
	if perp.dot(to_bat) < 0:
		perp = -perp
	dodge_velocity = perp * DODGE_STRENGTH
	dodge_cooldown = DODGE_COOLDOWN_TIME

# --- Shared ---

func _spawn_ring(dir: Vector2, spd: float) -> void:
	var proj := Projectile.new()
	var col := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 6.0
	col.shape = circle
	proj.add_child(col)

	var ring := _create_ring_visual()
	proj.add_child(ring)

	proj.setup(dir, 1, spd, false)
	proj.lifetime = 3.0
	proj.global_position = enemy.global_position
	enemy.get_tree().current_scene.call_deferred("add_child", proj)

func _create_ring_visual() -> Node2D:
	var container := Node2D.new()
	var outer := Polygon2D.new()
	var points: PackedVector2Array = []
	for i in 16:
		var a: float = TAU * i / 16.0
		points.append(Vector2(cos(a), sin(a)) * 8.0)
	outer.polygon = points
	outer.color = Color(1.0, 1.0, 1.0, 0.8)
	container.add_child(outer)
	var inner := Polygon2D.new()
	var inner_points: PackedVector2Array = []
	for i in 16:
		var a: float = TAU * i / 16.0
		inner_points.append(Vector2(cos(a), sin(a)) * 4.0)
	inner.polygon = inner_points
	inner.color = Color(0.7, 0.7, 1.0, 0.4)
	container.add_child(inner)
	return container

func _show_attack_anim() -> void:
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual and visual.sprite_frames.has_animation("attack"):
		visual.play("attack")

func _show_idle_anim() -> void:
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual and visual.sprite_frames.has_animation("fly"):
		visual.play("fly")
	elif visual:
		visual.play("default")

func _update_visual(delta: float) -> void:
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if not visual:
		return

	var tilt: float = clamp(enemy.velocity.y / 100.0, -0.3, 0.3)
	var target_rotation: float = tilt * 0.5 + sin(hover_time * 4.0) * 0.08
	visual.rotation = lerp_angle(visual.rotation, target_rotation, 8.0 * delta)

	if abs(enemy.velocity.x) > 10:
		visual.flip_h = enemy.velocity.x < 0

func apply_knockback(direction: Vector2, force: float) -> void:
	knockback_velocity = direction * force
	is_shooting = false
	is_spiraling = false
	shoot_timer = 1.5
