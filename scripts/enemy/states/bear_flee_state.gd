extends State

@export var enemy: CharacterBody2D
@export var flee_distance: float = 250.0
@export var spawn_cooldown: float = 4.0

var spawn_timer: float = 2.0
var knockback_velocity: Vector2 = Vector2.ZERO

func enter() -> void:
	spawn_timer = 2.0

func physics_process(delta: float) -> void:
	var player: Node2D = enemy.get_player()
	if not player:
		return

	# Handle knockback
	if knockback_velocity.length() > 5:
		enemy.velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 4.0 * delta)
		enemy.move_and_slide()
		return

	var to_player: Vector2 = player.global_position - enemy.global_position
	var dist: float = to_player.length()
	var dir_to_player := to_player.normalized()

	# Flee: move away from player when too close
	if dist < flee_distance:
		var flee_dir := -dir_to_player
		# Add slight perpendicular drift so the bear doesn't just back up in a straight line
		var perp := Vector2(-flee_dir.y, flee_dir.x)
		var drift := perp * sin(Time.get_ticks_msec() * 0.002) * 0.3
		enemy.velocity = (flee_dir + drift).normalized() * enemy.speed * 1.5
	elif dist > flee_distance + 80.0:
		# Too far, slowly drift closer to stay in range
		enemy.velocity = dir_to_player * enemy.speed * 0.5
	else:
		# In the sweet spot, wander sideways
		var perp := Vector2(-dir_to_player.y, dir_to_player.x)
		enemy.velocity = perp * sin(Time.get_ticks_msec() * 0.001) * enemy.speed
	enemy.move_and_slide()

	# Spawn worms
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_timer = randf_range(spawn_cooldown - 0.5, spawn_cooldown + 0.5)
		if enemy.has_method("get_alive_worm_count") and enemy.get_alive_worm_count() < enemy.max_worms:
			enemy.spawn_worm()

	# Update visual
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual and abs(enemy.velocity.x) > 5:
		visual.flip_h = enemy.velocity.x < 0

func apply_knockback(direction: Vector2, force: float) -> void:
	knockback_velocity = direction * force
