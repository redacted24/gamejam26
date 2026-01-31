extends Area2D
class_name Door

#var is_open: bool = true
#var _block_body: StaticBody2D
#var _trigger_area: Area2D
#var _visual: ColorRect

@export_file_path var next_level_path : String
@export var next_level_spawnpoint : String

func _ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		NavManager.go_to_level(next_level_path, next_level_spawnpoint)
	pass # Replace with function body.
