extends Node
class_name HealthComponent

signal health_changed(current_hp: int, max_hp: int)
signal died

@export var max_hp: int = 6
var current_hp: int

var invincible: bool = false

func _ready() -> void:
	current_hp = max_hp

func take_damage(amount: int) -> void:
	if invincible:
		return
	current_hp = max(current_hp - amount, 0)
	health_changed.emit(current_hp, max_hp)
	if current_hp <= 0:
		died.emit()

func heal(amount: int) -> void:
	current_hp = min(current_hp + amount, max_hp)
	health_changed.emit(current_hp, max_hp)
