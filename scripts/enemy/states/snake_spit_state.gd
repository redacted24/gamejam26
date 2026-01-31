extends State

@export var enemy: CharacterBody2D

var shoot_timer: float = 0.0
var is_fleeing: bool = false
var flee_timer: float = 0.0

# Knockback
var knockback_velocity: Vector2 = Vector2.ZERO

const FLEE_RANGE := 100.0
const PREFERRED_RANGE := 180.0
const FLEE_DURATION := 0.5

func enter() -> void:
	shoot_timer = randf_range(0.5, 1.5)
	is_fleeing = false
	knockback_velocity = Vector2.ZERO

func physics_process(delta: float) -> void:
	var player := enemy.get_player()
	if not player:
		enemy.velocity = Vector2.ZERO
		enemy.move_and_slide()
		return

	if knockback_velocity.length() > 5:
		enemy.velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 6.0 * delta)
		enemy.move_and_slide()
		return

	var dist: float = enemy.global_position.distance_to(player.global_position)
	var to_player: Vector2 = (player.global_position - enemy.global_position).normalized()

	# Flee if player gets too close
	if dist < FLEE_RANGE:
		is_fleeing = true
		flee_timer = FLEE_DURATION

	if is_fleeing:
		flee_timer -= delta
		enemy.velocity = -to_player * enemy.speed * 2.0
		enemy.move_and_slide()
		if flee_timer <= 0:
			is_fleeing = false
		_update_visual(to_player)
		return

	# Move to preferred range
	if dist > PREFERRED_RANGE + 30:
		enemy.velocity = to_player * enemy.speed
	elif dist < PREFERRED_RANGE - 30:
		enemy.velocity = -to_player * enemy.speed * 0.5
	else:
		# Strafe sideways
		var side := 1.0 if fmod(Time.get_ticks_msec(), 4000.0) < 2000.0 else -1.0
		var perp := Vector2(-to_player.y, to_player.x) * side
		enemy.velocity = perp * enemy.speed * 0.6
	enemy.move_and_slide()

	# Shoot
	shoot_timer -= delta
	if shoot_timer <= 0 and dist < 250:
		_spit(player)
		var snake := enemy as SnakeEnemy
		shoot_timer = snake.spit_cooldown + randf_range(-0.3, 0.3)

	_update_visual(to_player)

func _spit(player: Node2D) -> void:
	var snake := enemy as SnakeEnemy
	var base_dir: Vector2 = (player.global_position - enemy.global_position).normalized()

	# Shoot spread
	var half_spread: float = (snake.spit_count - 1) * snake.spit_spread / 2.0
	for i in range(snake.spit_count):
		var angle: float = -half_spread + i * snake.spit_spread
		var dir: Vector2 = base_dir.rotated(angle)

		var proj := Projectile.new()
		proj.global_position = enemy.global_position + dir * 15
		proj.setup(dir, snake.spit_damage, snake.spit_speed, false)
		enemy.get_tree().current_scene.add_child(proj)

	# Recoil visual
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		var tween := enemy.create_tween()
		tween.tween_property(visual, "position", -base_dir * 5, 0.05)
		tween.tween_property(visual, "position", Vector2.ZERO, 0.1)

func _update_visual(to_player: Vector2) -> void:
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		visual.flip_h = to_player.x < 0

func apply_knockback(direction: Vector2, force: float) -> void:
	knockback_velocity = direction * force
	is_fleeing = true
	flee_timer = 0.3
