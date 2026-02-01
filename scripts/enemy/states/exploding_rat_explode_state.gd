extends State

@export var enemy: CharacterBody2D

var wind_up_timer: float = 0.1
var has_exploded: bool = false
var base_scale: Vector2 = Vector2(0.25, 0.25)

func enter() -> void:
	enemy.velocity = Vector2.ZERO
	has_exploded = false
	wind_up_timer = 0.1

	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		base_scale = visual.scale

	# Wind-up animation: quick swell and flash
	if visual:
		var tween := enemy.create_tween()
		tween.tween_property(visual, "scale", base_scale * 1.8, 0.08).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(visual, "modulate", Color.RED, 0.08)

func physics_process(delta: float) -> void:
	if has_exploded:
		return

	wind_up_timer -= delta
	if wind_up_timer <= 0:
		_explode()

func _explode() -> void:
	has_exploded = true

	var exploding_rat := enemy as ExplodingRatEnemy
	var radius := exploding_rat.explosion_radius
	var dmg := exploding_rat.explosion_damage

	# Damage all players in range
	for player in get_tree().get_nodes_in_group("player"):
		var dist := enemy.global_position.distance_to(player.global_position)
		if dist < radius and player.has_method("take_damage"):
			player.take_damage(dmg, enemy.global_position)

	# Visual explosion effect
	_spawn_explosion_visual(radius)

	# Die
	EventBus.enemy_died.emit(enemy.global_position)
	enemy.queue_free()

func _spawn_explosion_visual(radius: float) -> void:
	# Create a simple expanding circle effect on the scene
	var effect := Node2D.new()
	effect.global_position = enemy.global_position
	enemy.get_tree().current_scene.add_child(effect)

	var circle := ColorRect.new()
	circle.color = Color(1.0, 0.3, 0.1, 0.7)
	circle.size = Vector2(radius * 2, radius * 2)
	circle.position = -Vector2(radius, radius)
	circle.pivot_offset = Vector2(radius, radius)
	effect.add_child(circle)

	# Expand and fade
	var tween := effect.create_tween()
	circle.scale = Vector2(0.2, 0.2)
	tween.tween_property(circle, "scale", Vector2(1.0, 1.0), 0.15).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(circle, "modulate:a", 0.0, 0.3)
	tween.tween_callback(effect.queue_free)
