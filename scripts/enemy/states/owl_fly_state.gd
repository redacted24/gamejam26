extends State

@export var enemy: CharacterBody2D

var circle_angle: float = 0.0
var drop_timer: float = 0.0
var orbit_radius: float = 120.0

# Knockback
var knockback_velocity: Vector2 = Vector2.ZERO

func enter() -> void:
	circle_angle = randf() * TAU
	drop_timer = randf_range(0.5, 1.0)
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

	# Orbit the player
	circle_angle += delta * 1.8
	var target_pos: Vector2 = player.global_position + Vector2.from_angle(circle_angle) * orbit_radius
	var to_target: Vector2 = (target_pos - enemy.global_position)

	if to_target.length() > 5:
		enemy.velocity = to_target.normalized() * enemy.speed * 1.5
	else:
		enemy.velocity = Vector2.ZERO
	enemy.move_and_slide()

	# Drop feathers at player
	drop_timer -= delta
	if drop_timer <= 0:
		_drop_feather(player)
		var owl := enemy as OwlEnemy
		drop_timer = owl.drop_cooldown + randf_range(-0.2, 0.3)

	# Face movement
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		visual.flip_h = enemy.velocity.x < 0

func _drop_feather(player: Node2D) -> void:
	var owl := enemy as OwlEnemy
	# Aim at where the player is (with slight lead)
	var dir: Vector2 = (player.global_position - enemy.global_position).normalized()

	var proj := Projectile.new()
	proj.global_position = enemy.global_position
	proj.setup(dir, owl.feather_damage, owl.feather_speed, false)
	enemy.get_tree().current_scene.add_child(proj)

func apply_knockback(direction: Vector2, force: float) -> void:
	knockback_velocity = direction * force
	drop_timer = 0.8
