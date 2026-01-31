extends State

func physics_process(_delta: float) -> void:
	var player: Player = get_parent().get_parent()
	player.try_shoot()

	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir == Vector2.ZERO:
		Transitioned.emit(self, "idle")
		return

	player.velocity = dir * player.stats.speed
	player.move_and_slide()
