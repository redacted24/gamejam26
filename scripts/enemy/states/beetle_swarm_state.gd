extends State

@export var enemy: CharacterBody2D

var jitter_timer: float = 0.0
var jitter_offset: Vector2 = Vector2.ZERO

# Knockback
var knockback_velocity: Vector2 = Vector2.ZERO

func enter() -> void:
	jitter_timer = 0.0
	knockback_velocity = Vector2.ZERO

func physics_process(delta: float) -> void:
	var player: Node2D = enemy.get_player()
	if not player:
		enemy.velocity = Vector2.ZERO
		enemy.move_and_slide()
		return

	if knockback_velocity.length() > 5:
		enemy.velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 8.0 * delta)
		enemy.move_and_slide()
		return

	var to_player: Vector2 = (player.global_position - enemy.global_position).normalized()

	# Erratic jitter movement
	jitter_timer -= delta
	if jitter_timer <= 0:
		jitter_timer = randf_range(0.03, 0.08)
		var angle := randf_range(-PI / 3, PI / 3)
		jitter_offset = to_player.rotated(angle)

	var speed_mult := randf_range(0.8, 1.5)
	enemy.velocity = jitter_offset * enemy.speed * speed_mult
	enemy.move_and_slide()

	# Deal contact damage
	var dist: float = enemy.global_position.distance_to(player.global_position)
	if dist < 20 and player.has_method("take_damage"):
		player.take_damage(enemy.contact_damage, enemy.global_position)

	# Rotate visual erratically
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		visual.rotation += delta * 10.0 * sign(jitter_offset.x)

func apply_knockback(direction: Vector2, force: float) -> void:
	knockback_velocity = direction * force
