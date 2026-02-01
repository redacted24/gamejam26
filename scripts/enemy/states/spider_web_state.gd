extends State

@export var enemy: CharacterBody2D

var shoot_timer: float = 0.0

# Knockback
var knockback_velocity: Vector2 = Vector2.ZERO

const MAX_RANGE := 250.0
const PREFERRED_RANGE := 200.0

func enter() -> void:
	shoot_timer = randf_range(1.0, 2.0)
	knockback_velocity = Vector2.ZERO

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

	var dist: float = enemy.global_position.distance_to(player.global_position)
	var to_player: Vector2 = (player.global_position - enemy.global_position).normalized()

	# Keep max distance — always try to back away
	if dist < PREFERRED_RANGE:
		enemy.velocity = -to_player * enemy.speed * 1.5
	elif dist > MAX_RANGE:
		enemy.velocity = to_player * enemy.speed * 0.5
	else:
		# Strafe
		var side := 1.0 if fmod(Time.get_ticks_msec(), 3000.0) < 1500.0 else -1.0
		enemy.velocity = Vector2(-to_player.y, to_player.x) * side * enemy.speed * 0.7
	enemy.move_and_slide()

	# Shoot webs
	shoot_timer -= delta
	if shoot_timer <= 0 and dist < MAX_RANGE:
		_shoot_web(player)
		var spider := enemy as SpiderEnemy
		shoot_timer = spider.web_cooldown + randf_range(-0.5, 0.5)

	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		visual.flip_h = to_player.x < 0

func _shoot_web(player: Node2D) -> void:
	var spider := enemy as SpiderEnemy
	var dir: Vector2 = (player.global_position - enemy.global_position).normalized()

	# Shoot web projectile that creates slow zone on impact
	var proj := Projectile.new()
	proj.global_position = enemy.global_position + dir * 15
	proj.setup(dir, 0, spider.web_speed, false)
	proj.lifetime = 1.5
	enemy.get_tree().current_scene.add_child(proj)

	# Override the projectile's hit behavior to spawn slow zone
	# We connect to body_entered before the projectile's own connection
	proj.body_entered.connect(func(body: Node2D):
		_spawn_slow_zone(proj.global_position, spider)
	)

	# Also spawn zone when projectile expires
	proj.tree_exiting.connect(func():
		if proj.is_inside_tree():
			_spawn_slow_zone(proj.global_position, spider)
	)

func _spawn_slow_zone(pos: Vector2, spider: SpiderEnemy) -> void:
	var zone := Area2D.new()
	zone.global_position = pos
	zone.collision_layer = 0
	zone.collision_mask = 2  # player layer
	zone.monitoring = true

	var col := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = spider.web_slow_radius
	col.shape = circle
	zone.add_child(col)

	# Visual: semi-transparent grey circle
	var visual := ColorRect.new()
	var size: float = spider.web_slow_radius * 2
	visual.size = Vector2(size, size)
	visual.position = -Vector2(spider.web_slow_radius, spider.web_slow_radius)
	visual.color = Color(0.8, 0.8, 0.8, 0.3)
	zone.add_child(visual)

	enemy.get_tree().current_scene.add_child(zone)

	# Slow player while inside
	var slowed_players: Array = []
	zone.body_entered.connect(func(body: Node2D):
		if body.is_in_group("player") and body is CharacterBody2D:
			slowed_players.append(body)
			body.stats.speed *= 0.4
	)
	zone.body_exited.connect(func(body: Node2D):
		if body in slowed_players:
			slowed_players.erase(body)
			body.stats.speed /= 0.4
	)

	# Remove after duration
	var tween := zone.create_tween()
	tween.tween_interval(spider.web_slow_duration - 0.5)
	tween.tween_property(visual, "color:a", 0.0, 0.5)
	tween.tween_callback(func():
		# Restore speed for anyone still inside
		for p in slowed_players:
			if is_instance_valid(p):
				p.stats.speed /= 0.4
		zone.queue_free()
	)

func apply_knockback(direction: Vector2, force: float) -> void:
	knockback_velocity = direction * force
