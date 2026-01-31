extends State
class_name EnemyIdleState

@export var enemy : CharacterBody2D
@export var idle_duration: float = 1.0

var _timer: float = 0.0

func enter() -> void:
	_timer = 0.0
	enemy.velocity = Vector2.ZERO

func process(delta: float) -> void:
	pass
