extends State
class_name EnemyDashState

@export var dash_speed: float = 400.0
@export var dash_duration: float = 0.4

var _timer: float = 0.0
var _dash_direction: Vector2 = Vector2.ZERO

func enter() -> void:
	_timer = 0.0
	var enemy: EnemyBase = get_parent().get_parent()
	var player := enemy.get_player()
	if player:
		_dash_direction = (player.global_position - enemy.global_position).normalized()
	else:
		_dash_direction = Vector2.RIGHT

func physics_process(delta: float) -> void:
	_timer += delta
	var enemy: EnemyBase = get_parent().get_parent()
	enemy.velocity = _dash_direction * dash_speed
	enemy.move_and_slide()

	if _timer >= dash_duration:
		Transitioned.emit(self, "idle")
