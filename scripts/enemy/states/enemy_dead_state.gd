extends State
class_name EnemyDeadState

func enter() -> void:
	var enemy: EnemyBase = get_parent().get_parent()
	enemy.velocity = Vector2.ZERO
	enemy.collision_layer = 0
	enemy.collision_mask = 0

	var hitbox := enemy.get_node_or_null("Hitbox")
	if hitbox:
		hitbox.monitoring = false

	var tween := enemy.create_tween()
	tween.tween_property(enemy, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(enemy.queue_free)
