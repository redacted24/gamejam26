extends State

@export var enemy: CharacterBody2D
@export var charge_range: float = 200.0

# Knockback
var knockback_velocity: Vector2 = Vector2.ZERO

func enter() -> void:
	knockback_velocity = Vector2.ZERO

func physics_process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
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

	var dist: float = enemy.global_position.distance_to(player.global_position)
	var to_player: Vector2 = (player.global_position - enemy.global_position).normalized()

	# Walk toward player
	enemy.velocity = to_player * enemy.speed
	enemy.move_and_slide()

	# Face direction
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		visual.flip_h = to_player.x < 0

	# Start charge when close enough
	if dist < charge_range:
		Transitioned.emit(self, "Charge")

func apply_knockback(direction: Vector2, force: float) -> void:
	knockback_velocity = direction * force
