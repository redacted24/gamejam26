extends State

func enter() -> void:
	var player: Player = get_parent().get_parent()
	player.velocity = Vector2.ZERO

func physics_process(_delta: float) -> void:
	var player: Player = get_parent().get_parent()
	player.try_attack()

	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir != Vector2.ZERO:
		Transitioned.emit(self, "move")
