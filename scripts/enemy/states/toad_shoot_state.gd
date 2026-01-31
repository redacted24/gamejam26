extends State

@export var enemy: CharacterBody2D

var shoot_timer: float = 1.0
var is_charging: bool = false
var charge_timer: float = 0.0

# Hop movement
var hop_timer: float = 0.0
var is_hopping: bool = false
var hop_dir: Vector2 = Vector2.ZERO

# Base scale (read from sprite on enter)
var base_scale: Vector2 = Vector2(0.1, 0.1)

# Knockback
var knockback_velocity: Vector2 = Vector2.ZERO

func enter() -> void:
	shoot_timer = randf_range(0.5, 1.5)
	hop_timer = randf_range(0.8, 1.5)
	is_charging = false
	is_hopping = false
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		base_scale = visual.scale

func physics_process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return

	# Handle knockback
	if knockback_velocity.length() > 5:
		enemy.velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 8.0 * delta)
		enemy.move_and_slide()
		return

	# Hop movement
	_do_hop(delta, player)
	enemy.move_and_slide()

	# Face player
	_update_visual(delta, player)

	if is_charging:
		_do_charge(delta, player)
	else:
		_do_idle(delta, player)

func _do_idle(delta: float, player: Node2D) -> void:
	shoot_timer -= delta

	var dist := enemy.global_position.distance_to(player.global_position)

	# Only shoot if player is in range
	if shoot_timer <= 0 and dist < 250:
		is_charging = true
		charge_timer = 0.4  # Wind up time
		_start_charge()

func _do_hop(delta: float, player: Node2D) -> void:
	if is_charging:
		enemy.velocity = Vector2.ZERO
		return

	hop_timer -= delta
	if hop_timer <= 0 and not is_hopping:
		is_hopping = true
		var to_player := (player.global_position - enemy.global_position).normalized()
		var dist := enemy.global_position.distance_to(player.global_position)

		if dist < 120:
			# Too close — hop away from player
			hop_dir = -to_player
		elif dist > 300:
			# Too far — hop toward player
			hop_dir = to_player
		else:
			# Comfortable range — hop sideways
			var side := 1.0 if randf() > 0.5 else -1.0
			hop_dir = Vector2(-to_player.y, to_player.x) * side

		hop_timer = 0.4  # Hop duration

		# Squash and stretch for hop
		var visual := enemy.get_node("AnimatedSprite2D")
		var tween := enemy.create_tween()
		tween.tween_property(visual, "scale", base_scale * Vector2(1.2, 0.8), 0.08)
		tween.tween_property(visual, "scale", base_scale, 0.17)

	if is_hopping:
		enemy.velocity = hop_dir * enemy.speed * 3.5
		hop_timer -= delta
		if hop_timer <= 0:
			is_hopping = false
			hop_timer = randf_range(0.6, 1.2)
			enemy.velocity = Vector2.ZERO
	else:
		enemy.velocity = Vector2.ZERO

func _start_charge() -> void:
	# Visual feedback - squash down
	var visual := enemy.get_node("AnimatedSprite2D")
	var tween := enemy.create_tween()
	tween.tween_property(visual, "scale", base_scale * Vector2(1.3, 0.7), 0.2)
	tween.tween_property(visual, "scale", base_scale * Vector2(0.8, 1.3), 0.15)

func _do_charge(delta: float, player: Node2D) -> void:
	charge_timer -= delta

	if charge_timer <= 0:
		_shoot(player)
		is_charging = false
		shoot_timer = enemy.shoot_cooldown + randf_range(-0.3, 0.3)

		# Return to normal scale
		var visual := enemy.get_node("AnimatedSprite2D")
		var tween := enemy.create_tween()
		tween.tween_property(visual, "scale", base_scale, 0.2)

func _shoot(player: Node2D) -> void:
	var dir: Vector2 = (player.global_position - enemy.global_position).normalized()

	var proj := Projectile.new()
	proj.global_position = enemy.global_position + dir * 15
	proj.setup(dir, enemy.projectile_damage, enemy.projectile_speed, false)
	enemy.get_tree().current_scene.add_child(proj)

func _update_visual(delta: float, player: Node2D) -> void:
	var visual := enemy.get_node("AnimatedSprite2D")
	var dir: Vector2 = (player.global_position - enemy.global_position).normalized()

	# Slight tilt towards player
	var target_rot: float = dir.angle() * 0.2
	visual.rotation = lerp_angle(visual.rotation, target_rot, 5.0 * delta)

	# Flip to face player
	visual.flip_h = player.global_position.x < enemy.global_position.x

func apply_knockback(direction: Vector2, force: float) -> void:
	knockback_velocity = direction * force
	is_charging = false
	shoot_timer = 0.8  # Brief delay after getting hit
