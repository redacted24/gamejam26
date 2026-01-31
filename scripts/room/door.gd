extends Area2D
class_name Door

@export_file_path var next_level_path : String
@export var next_level_spawnpoint : String

func _ready() -> void:
	get_node("ColorRect").queue_free()
	pass

func _on_body_entered(body: Node2D) -> void:
	print("switching rooms")
	if body.is_in_group("player"):
		NavManager.go_to_level(next_level_path, next_level_spawnpoint)
	pass # Replace with function body.
