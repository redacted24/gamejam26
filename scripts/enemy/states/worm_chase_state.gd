extends State

@export var enemy: CharacterBody2D

var wobble_time: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO

func enter() -> void:
	wobble_time = randf() * TAU

func physics_process(delta: float) -> void:
	var player: Node2D = enemy.get_player()
	if not player:
		return

	# Handle knockback
	if knockback_velocity.length() > 5:
		enemy.velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 6.0 * delta)
		enemy.move_and_slide()
		return

	var to_player: Vector2 = (player.global_position - enemy.global_position).normalized()
	var dist: float = enemy.global_position.distance_to(player.global_position)

	# Slight wobble for organic movement
	wobble_time += delta * 5.0
	var wobble := Vector2(cos(wobble_time), sin(wobble_time)) * 0.3
	var move_dir := (to_player + wobble).normalized()

	enemy.velocity = move_dir * enemy.speed
	enemy.move_and_slide()

	# Deal contact damage
	if dist < 20 and player.has_method("take_damage"):
		player.take_damage(enemy.contact_damage, enemy.global_position)

	# Update visual
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual and abs(enemy.velocity.x) > 5:
		visual.flip_h = enemy.velocity.x < 0

func apply_knockback(direction: Vector2, force: float) -> void:
	knockback_velocity = direction * force
