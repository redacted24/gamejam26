extends State

@export var enemy: CharacterBody2D

enum Phase { CIRCLING, WINDING_UP, DASHING, RECOVERING }

var phase: int = Phase.CIRCLING
var timer: float = 0.0
var circle_angle: float = 0.0
var dash_dir: Vector2 = Vector2.ZERO
var has_hit: bool = false

# Knockback
var knockback_velocity: Vector2 = Vector2.ZERO

const CIRCLE_DURATION := 2.0
const WIND_UP_TIME := 0.3
const DASH_TIME := 0.25
const RECOVERY_TIME := 0.8

func enter() -> void:
	phase = Phase.CIRCLING
	timer = CIRCLE_DURATION + randf_range(-0.5, 0.5)
	circle_angle = randf() * TAU
	knockback_velocity = Vector2.ZERO
	has_hit = false

func physics_process(delta: float) -> void:
	var player: Node2D = enemy.get_player()
	if not player:
		enemy.velocity = Vector2.ZERO
		enemy.move_and_slide()
		return

	if knockback_velocity.length() > 5:
		enemy.velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 6.0 * delta)
		enemy.move_and_slide()
		return

	timer -= delta

	match phase:
		Phase.CIRCLING:
			_do_circle(delta, player)
		Phase.WINDING_UP:
			_do_wind_up(delta, player)
		Phase.DASHING:
			_do_dash(delta, player)
		Phase.RECOVERING:
			_do_recovery(delta)

	# Face movement direction
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual and enemy.velocity.length() > 10:
		visual.flip_h = enemy.velocity.x < 0

func _do_circle(delta: float, player: Node2D) -> void:
	# Circle around the player to get behind them
	circle_angle += delta * 2.5
	var target_dist: float = 100.0
	var orbit_pos: Vector2 = player.global_position + Vector2.from_angle(circle_angle) * target_dist
	var to_orbit: Vector2 = (orbit_pos - enemy.global_position).normalized()

	enemy.velocity = to_orbit * enemy.speed
	enemy.move_and_slide()

	if timer <= 0:
		phase = Phase.WINDING_UP
		timer = WIND_UP_TIME
		enemy.velocity = Vector2.ZERO

func _do_wind_up(delta: float, player: Node2D) -> void:
	# Lock dash direction through the player
	dash_dir = (player.global_position - enemy.global_position).normalized()
	enemy.velocity = Vector2.ZERO

	# Visual: crouch
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual and timer > WIND_UP_TIME - 0.05:
		var tween := enemy.create_tween()
		tween.tween_property(visual, "modulate", Color(1.0, 0.6, 0.6), WIND_UP_TIME)

	if timer <= 0:
		phase = Phase.DASHING
		timer = DASH_TIME
		has_hit = false

func _do_dash(delta: float, player: Node2D) -> void:
	var wolf := enemy as WolfEnemy
	enemy.velocity = dash_dir * wolf.dash_speed
	enemy.move_and_slide()

	# Check hit (pass through, don't stop)
	if not has_hit:
		var dist: float = enemy.global_position.distance_to(player.global_position)
		if dist < 30 and player.has_method("take_damage"):
			player.take_damage(wolf.dash_damage, enemy.global_position)
			has_hit = true

	if timer <= 0:
		phase = Phase.RECOVERING
		timer = RECOVERY_TIME
		enemy.velocity = Vector2.ZERO
		# Reset visual
		var visual := enemy.get_node_or_null("AnimatedSprite2D")
		if visual:
			var tween := enemy.create_tween()
			tween.tween_property(visual, "modulate", Color.WHITE, 0.2)

func _do_recovery(delta: float) -> void:
	# Slow down after dash
	enemy.velocity = enemy.velocity.lerp(Vector2.ZERO, 5.0 * delta)
	enemy.move_and_slide()

	if timer <= 0:
		phase = Phase.CIRCLING
		timer = CIRCLE_DURATION + randf_range(-0.3, 0.5)
		circle_angle = randf() * TAU

func apply_knockback(direction: Vector2, force: float) -> void:
	knockback_velocity = direction * force
	if phase == Phase.DASHING:
		phase = Phase.RECOVERING
		timer = RECOVERY_TIME
