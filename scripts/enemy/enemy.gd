extends CharacterBody2D
class_name EnemyBase

@export var health_component : HealthComponent
@export var speed: float = 100.0
@export var contact_damage: int = 1

var _max_hp: int = 3

func _ready() -> void:
	health_component.died.connect(_on_died)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and body.is_in_group("player"):
		body.take_damage(contact_damage)

func _on_died() -> void:
	print("enemy died")
	EventBus.enemy_died.emit(global_position)
	queue_free()

func take_damage(amount: int) -> void:
	print("enemy took damage %d" % amount)
	health_component.take_damage(amount)
