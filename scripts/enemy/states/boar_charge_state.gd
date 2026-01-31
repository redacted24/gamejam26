extends State

@export var enemy: CharacterBody2D

enum Phase { WIND_UP, CHARGING, RECOVERY }

var phase: int = Phase.WIND_UP
var charge_dir: Vector2 = Vector2.ZERO
var timer: float = 0.0
var distance_traveled: float = 0.0
var base_scale: Vector2 = Vector2(0.35, 0.35)

const MAX_CHARGE_DIST := 250.0
const WIND_UP_TIME := 0.5
const RECOVERY_TIME := 1.5

# Knockback
var knockback_velocity: Vector2 = Vector2.ZERO

func enter() -> void:
	phase = Phase.WIND_UP
	timer = WIND_UP_TIME
	distance_traveled = 0.0
	knockback_velocity = Vector2.ZERO
	enemy.velocity = Vector2.ZERO

	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		base_scale = visual.scale

	# Lock charge direction toward player
	var player := get_tree().get_first_node_in_group("player")
	if player:
		charge_dir = (player.global_position - enemy.global_position).normalized()
	else:
		charge_dir = Vector2.RIGHT

	# Wind-up visual: pull back and shake
	if visual:
		var tween := enemy.create_tween()
		tween.tween_property(visual, "position", -charge_dir * 8, 0.15)
		tween.tween_property(visual, "modulate", Color(1.0, 0.5, 0.3), 0.1)
		# Shake
		for i in range(4):
			var offset := Vector2(randf_range(-3, 3), randf_range(-3, 3))
			tween.tween_property(visual, "position", -charge_dir * 8 + offset, 0.04)
		tween.tween_property(visual, "position", Vector2.ZERO, 0.05)

func physics_process(delta: float) -> void:
	# Handle knockback in any phase
	if knockback_velocity.length() > 5:
		enemy.velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 6.0 * delta)
		enemy.move_and_slide()
		return

	match phase:
		Phase.WIND_UP:
			_do_wind_up(delta)
		Phase.CHARGING:
			_do_charge(delta)
		Phase.RECOVERY:
			_do_recovery(delta)

func _do_wind_up(delta: float) -> void:
	enemy.velocity = Vector2.ZERO
	timer -= delta
	if timer <= 0:
		phase = Phase.CHARGING
		distance_traveled = 0.0
		# Flash white on charge start
		var visual := enemy.get_node_or_null("AnimatedSprite2D")
		if visual:
			var tween := enemy.create_tween()
			tween.tween_property(visual, "modulate", Color.WHITE, 0.05)

func _do_charge(delta: float) -> void:
	var boar := enemy as BoarEnemy
	var speed: float = boar.charge_speed
	enemy.velocity = charge_dir * speed

	var moved: float = speed * delta
	distance_traveled += moved
	enemy.move_and_slide()

	# Face charge direction
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		visual.flip_h = charge_dir.x < 0

	# End charge after max distance
	if distance_traveled >= MAX_CHARGE_DIST:
		_end_charge()

func _end_charge() -> void:
	enemy.velocity = Vector2.ZERO
	phase = Phase.RECOVERY
	timer = RECOVERY_TIME

	# Spawn cone AoE
	_spawn_cone_aoe()

	# Recovery visual: briefly stunned look
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		var tween := enemy.create_tween()
		tween.tween_property(visual, "modulate", Color(0.7, 0.7, 0.7), 0.1)
		tween.tween_property(visual, "modulate", Color.WHITE, RECOVERY_TIME - 0.2)

func _spawn_cone_aoe() -> void:
	var boar := enemy as BoarEnemy
	var cone_length: float = 100.0
	var cone_half_angle: float = PI / 4.0  # 45° each side = 90° total

	# Calculate cone triangle points
	var tip := Vector2.ZERO
	var left := charge_dir.rotated(-cone_half_angle) * cone_length
	var right := charge_dir.rotated(cone_half_angle) * cone_length

	# Create Area2D for the cone
	var cone := Area2D.new()
	cone.global_position = enemy.global_position
	cone.collision_layer = 0
	cone.collision_mask = 2  # player layer
	cone.monitoring = true
	cone.monitorable = false

	var shape := CollisionPolygonShape(tip, left, right)
	cone.add_child(shape)

	# Visual: draw the cone
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([tip, left, right])
	polygon.color = Color(1.0, 0.8, 0.2, 0.5)
	cone.add_child(polygon)

	enemy.get_tree().current_scene.add_child(cone)

	# Track if we already hit the player
	var hit := [false]

	# Check for player overlap after a physics frame
	cone.body_entered.connect(func(body: Node2D):
		if hit[0]:
			return
		if body.is_in_group("player") and body.has_method("take_damage"):
			hit[0] = true
			body.take_damage(boar.charge_damage, enemy.global_position)
			_push_player(body)
	)

	# Also check immediately for bodies already inside
	await enemy.get_tree().physics_frame
	if not hit[0]:
		for body in cone.get_overlapping_bodies():
			if body.is_in_group("player") and body.has_method("take_damage"):
				hit[0] = true
				body.take_damage(boar.charge_damage, enemy.global_position)
				_push_player(body)
				break

	# Fade out and remove
	var tween := cone.create_tween()
	tween.tween_property(polygon, "color:a", 0.0, 0.3)
	tween.tween_callback(cone.queue_free)

func _push_player(player: Node2D) -> void:
	var push_dir: Vector2 = (player.global_position - enemy.global_position).normalized()
	# Strong knockback push
	var push_force: float = 500.0
	var sm := player.get_node_or_null("StateMachine")
	if sm:
		sm.on_state_transition(sm.current_state, "hurt")
	# Apply velocity directly for the push
	player.velocity = push_dir * push_force

func _do_recovery(delta: float) -> void:
	enemy.velocity = Vector2.ZERO
	timer -= delta
	if timer <= 0:
		Transitioned.emit(self, "Walk")

func apply_knockback(direction: Vector2, force: float) -> void:
	knockback_velocity = direction * force
	if phase == Phase.CHARGING:
		_end_charge()

static func CollisionPolygonShape(a: Vector2, b: Vector2, c: Vector2) -> CollisionPolygon2D:
	var col := CollisionPolygon2D.new()
	col.polygon = PackedVector2Array([a, b, c])
	return col
