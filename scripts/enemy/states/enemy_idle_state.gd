extends State
class_name EnemyIdleState

@export var idle_duration: float = 1.0
@export var next_state_name: String = "chase"

var _timer: float = 0.0

func enter() -> void:
	_timer = 0.0
	var enemy: EnemyBase = get_parent().get_parent()
	enemy.velocity = Vector2.ZERO

func process(delta: float) -> void:
	_timer += delta
	if _timer >= idle_duration:
		Transitioned.emit(self, next_state_name)
