extends State
class_name EnemyChaseState

@export var enemy: CharacterBody2D
@export var turn_speed: float = 10.0

# Rat scurry behavior
var scurry_timer: float = 0.0
var is_moving: bool = true
var current_speed: float = 0.0
var wobble_offset: Vector2 = Vector2.ZERO

# Knockback
var knockback_velocity: Vector2 = Vector2.ZERO

func enter() -> void:
	scurry_timer = 0.0
	is_moving = true

func physics_process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	# Handle knockback first
	if knockback_velocity.length() > 5:
		enemy.velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 8.0 * delta)
		enemy.move_and_slide()
		return
	
	# Scurry timer
	scurry_timer -= delta
	if scurry_timer <= 0:
		_new_scurry_cycle()
	
	# Direction to player with wobble
	var target_dir: Vector2 = (player.global_position - enemy.global_position).normalized()
	var final_dir: Vector2 = (target_dir + wobble_offset).normalized()
	
	# Apply velocity
	if is_moving:
		enemy.velocity = final_dir * current_speed
	else:
		enemy.velocity = enemy.velocity.lerp(Vector2.ZERO, 15.0 * delta)
	
	enemy.move_and_slide()
	
	# Rotate visual towards movement
	if enemy.velocity.length() > 5:
		var visual := enemy.get_node("AnimatedSprite2D")
		var target_angle := final_dir.angle()
		visual.rotation = lerp_angle(visual.rotation, target_angle, turn_speed * delta)

func _new_scurry_cycle() -> void:
	# Randomly pause sometimes
	if is_moving and randf() < 0.2:
		is_moving = false
		scurry_timer = randf_range(0.05, 0.15)  # Brief pause
	else:
		is_moving = true
		scurry_timer = randf_range(0.1, 0.3)  # Scurry burst
		current_speed = randf_range(enemy.speed * 0.7, enemy.speed * 1.4)
		# Random wobble direction
		wobble_offset = Vector2(randf_range(-0.3, 0.3), randf_range(-0.3, 0.3))

func apply_knockback(direction: Vector2, force: float) -> void:
	knockback_velocity = direction * force
	is_moving = false
	scurry_timer = 0.2  # Brief stun after knockback
