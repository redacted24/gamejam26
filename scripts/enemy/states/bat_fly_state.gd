extends State

@export var enemy: CharacterBody2D

var angle: float = 0.0
var swoop_timer: float = 2.0
var is_swooping: bool = false
var is_retreating: bool = false
var swoop_target: Vector2 = Vector2.ZERO
var retreat_dir: Vector2 = Vector2.ZERO

# Hover behavior
var base_height: float = -60.0
var hover_time: float = 0.0

# Knockback
var knockback_velocity: Vector2 = Vector2.ZERO

func enter() -> void:
	angle = randf() * TAU
	swoop_timer = randf_range(2.0, 4.0)
	is_swooping = false
	is_retreating = false

func physics_process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	# Handle knockback
	if knockback_velocity.length() > 5:
		enemy.velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 3.0 * delta)
		enemy.move_and_slide()
		return
	
	hover_time += delta
	
	if is_retreating:
		_do_retreat(delta, player)
	elif is_swooping:
		_do_swoop(delta, player)
	else:
		_do_hover(delta, player)
	
	enemy.move_and_slide()
	_update_visual(delta)

func _do_hover(delta: float, player: Node2D) -> void:
	angle += delta * 1.2
	
	var offset := Vector2(
		sin(angle) * 70.0,
		base_height + sin(angle * 2.0) * 25.0 + sin(hover_time * 3.0) * 8.0
	)
	
	var target_pos := player.global_position + offset
	var dir := (target_pos - enemy.global_position)
	
	enemy.velocity = enemy.velocity.lerp(dir * 2.0, 3.0 * delta)
	
	swoop_timer -= delta
	if swoop_timer <= 0:
		_start_swoop(player)

func _start_swoop(player: Node2D) -> void:
	is_swooping = true
	swoop_target = player.global_position

func _do_swoop(delta: float, player: Node2D) -> void:
	swoop_target = player.global_position
	
	var to_target := swoop_target - enemy.global_position
	var dist := to_target.length()
	
	swoop_timer -= delta
	
	# End swoop if close enough OR timeout
	if dist < 30 or swoop_timer <= 0:
		is_swooping = false
		is_retreating = true
		swoop_timer = 0.6
		retreat_dir = (enemy.global_position - player.global_position).normalized()
		retreat_dir.y = -abs(retreat_dir.y) - 0.5
		retreat_dir = retreat_dir.normalized()
		return
	
	var swoop_dir := to_target.normalized()
	enemy.velocity = enemy.velocity.lerp(swoop_dir * 300.0, 12.0 * delta)

func _do_retreat(delta: float, _player: Node2D) -> void:
	# Fly backward and up quickly
	enemy.velocity = enemy.velocity.lerp(retreat_dir * 180.0, 6.0 * delta)
	
	swoop_timer -= delta
	if swoop_timer <= 0:
		is_retreating = false
		swoop_timer = randf_range(2.5, 4.5)

func _update_visual(delta: float) -> void:
	var visual := enemy.get_node("AnimatedSprite2D")
	
	var tilt: float = clamp(enemy.velocity.y / 100.0, -0.5, 0.5)
	var target_rotation: float = tilt * 0.8
	
	target_rotation += sin(hover_time * 6.0) * 0.1
	
	visual.rotation = lerp_angle(visual.rotation, target_rotation, 10.0 * delta)
	
	if abs(enemy.velocity.x) > 10:
		visual.flip_h = enemy.velocity.x < 0

func apply_knockback(direction: Vector2, force: float) -> void:
	knockback_velocity = direction * force
	is_swooping = false
	is_retreating = false
	swoop_timer = 1.5
