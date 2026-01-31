extends State

func enter() -> void:
	var player: Player = get_parent().get_parent()
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	player.collision_layer = 0
	player.collision_mask = 0

	var tween := player.create_tween()
	tween.tween_property(player, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): EventBus.player_died.emit(player.peer_id))
