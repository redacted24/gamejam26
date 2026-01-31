extends Area2D
class_name HurtboxComponent

signal hurt(damage: int)

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		hurt.emit(area.damage)
