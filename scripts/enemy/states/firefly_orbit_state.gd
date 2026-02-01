extends State

@export var enemy: CharacterBody2D

var orbit_angle: float = 0.0
var orbit_speed: float = 3.0
var orbit_radius: float = 100.0
var ring_timer: float = 0.0
var is_charging: bool = false
var charge_timer: float = 0.0
var base_scale: Vector2 = Vector2(0.15, 0.15)

# Knockback
var knockback_velocity: Vector2 = Vector2.ZERO

const CHARGE_TIME := 0.6

func enter() -> void:
	orbit_angle = randf() * TAU
	ring_timer = randf_range(1.5, 2.5)
	is_charging = false
	knockback_velocity = Vector2.ZERO

	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		base_scale = visual.scale

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

	# Erratic orbit around player
	orbit_angle += delta * orbit_speed
	orbit_speed = 2.5 + sin(Time.get_ticks_msec() * 0.003) * 1.5
	orbit_radius = 100.0 + sin(Time.get_ticks_msec() * 0.002) * 40.0

	var target_pos: Vector2 = player.global_position + Vector2.from_angle(orbit_angle) * orbit_radius
	var to_target: Vector2 = (target_pos - enemy.global_position)
	if to_target.length() > 5:
		enemy.velocity = to_target.normalized() * enemy.speed * 1.8
	else:
		enemy.velocity = Vector2.ZERO
	enemy.move_and_slide()

	# Charge up and fire ring
	if is_charging:
		charge_timer -= delta
		# Glow brighter during charge
		var visual := enemy.get_node_or_null("AnimatedSprite2D")
		if visual:
			var pulse: float = abs(sin(charge_timer * 15.0))
			visual.modulate = Color(1.0 + pulse * 0.5, 1.0 + pulse * 0.3, 0.5, 1.0)

		if charge_timer <= 0:
			_fire_ring()
			is_charging = false
			var firefly := enemy as FireflyEnemy
			ring_timer = firefly.ring_cooldown + randf_range(-0.5, 0.5)
			if visual:
				var tween := enemy.create_tween()
				tween.tween_property(visual, "modulate", Color.WHITE, 0.3)
	else:
		ring_timer -= delta
		if ring_timer <= 0:
			is_charging = true
			charge_timer = CHARGE_TIME

	# Bob up and down
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual and not is_charging:
		visual.position.y = sin(Time.get_ticks_msec() * 0.005) * 3.0

func _fire_ring() -> void:
	var firefly := enemy as FireflyEnemy
	var count: int = firefly.ring_count

	for i in range(count):
		var angle: float = (TAU / count) * i
		var dir: Vector2 = Vector2.from_angle(angle)

		var proj := Projectile.new()
		proj.global_position = enemy.global_position
		proj.setup(dir, firefly.ring_damage, firefly.ring_speed, false)
		enemy.get_tree().current_scene.add_child(proj)

	# Burst visual - flash and scale pop
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		var tween := enemy.create_tween()
		tween.tween_property(visual, "scale", base_scale * 1.5, 0.05)
		tween.tween_property(visual, "scale", base_scale, 0.15)

func apply_knockback(direction: Vector2, force: float) -> void:
	knockback_velocity = direction * force
	is_charging = false
	ring_timer = 1.0
