extends State

const HURT_DURATION := 0.8
const FLASH_SPEED := 15.0

var _timer: float = 0.0

func enter() -> void:
	var player: Player = get_parent().get_parent()
	player.invincible = true
	_timer = 0.0

func exit() -> void:
	var player: Player = get_parent().get_parent()
	player.invincible = false
	var visual := player.get_node("Visual")
	if visual:
		visual.modulate = Color.WHITE

func process(delta: float) -> void:
	_timer += delta
	var player: Player = get_parent().get_parent()

	var visual := player.get_node("Visual")
	if visual:
		visual.modulate.a = 0.3 + 0.7 * abs(sin(_timer * FLASH_SPEED))

	if _timer >= HURT_DURATION:
		Transitioned.emit(self, "idle")

func physics_process(_delta: float) -> void:
	var player: Player = get_parent().get_parent()
	if not player.is_multiplayer_authority():
		return
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player.velocity = dir * player.stats.speed * 0.5
	player.move_and_slide()
