extends State
class_name EnemyWanderState

@export var direction_change_time: float = 1.5

var _timer: float = 0.0
var _direction: Vector2 = Vector2.ZERO

func enter() -> void:
	_pick_direction()
	_timer = 0.0

func physics_process(delta: float) -> void:
	_timer += delta
	if _timer >= direction_change_time:
		_pick_direction()
		_timer = 0.0

	var enemy: EnemyBase = get_parent().get_parent()
	enemy.velocity = _direction * enemy.speed
	enemy.move_and_slide()

func _pick_direction() -> void:
	var angle := randf() * TAU
	_direction = Vector2(cos(angle), sin(angle))
