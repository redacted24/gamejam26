extends State
class_name EnemyChaseState

@export var enemy: CharacterBody2D
@export var turn_speed: float = 8.0

# Rat-like movement
var scurry_timer: float = 0.0
var scurry_duration: float = 0.2
var pause_duration: float = 0.1
var is_scurrying: bool = true
var current_dir: Vector2 = Vector2.ZERO

# Knockback
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 10.0

func physics_process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	# Handle knockback
	if knockback_velocity.length() > 10:
		enemy.velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, knockback_decay * delta)
		enemy.move_and_slide()
		return
	
	knockback_velocity = Vector2.ZERO
	
	# Scurry timer - alternates between moving and brief pauses
	scurry_timer -= delta
	if scurry_timer <= 0:
		is_scurrying = !is_scurrying
		scurry_timer = scurry_duration if is_scurrying else pause_duration
		# Randomize timing slightly
		scurry_timer *= randf_range(0.8, 1.2)
	
	# Get direction to player
	var target_dir: Vector2 = (player.global_position - enemy.global_position).normalized()
	
	# Add slight wobble when scurrying
	if is_scurrying:
		var wobble := Vector2(randf_range(-0.2, 0.2), randf_range(-0.2, 0.2))
		current_dir = (target_dir + wobble).normalized()
		enemy.velocity = current_dir * enemy.speed * randf_range(1.0, 1.3)
	else:
		enemy.velocity = current_dir * enemy.speed * 0.3  # Slow down during pause
	
	enemy.move_and_slide()
	
	# Rotate visual
	var visual := enemy.get_node("AnimatedSprite2D")
	var target_angle := current_dir.angle()
	visual.rotation = lerp_angle(visual.rotation, target_angle, turn_speed * delta)

func apply_knockback(direction: Vector2, force: float) -> void:
	knockback_velocity = direction * force
