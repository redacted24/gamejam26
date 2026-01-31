extends Area2D
class_name Door

var next_level = {
	"path": "",
	"spawnpoint": "",
	"level_type": MapGeneration.room_types
}
var next_level_path : String
var next_level_spawnpoint : String
var next_level_type : MapGeneration.room_types

func _ready() -> void:
	get_node("ColorRect").queue_free()
	pass

func _on_body_entered(body: Node2D) -> void:
	assert(next_level_path != null)
	if body.is_in_group("player"):
		print("Door entered: switching rooms to %s" % next_level_path)
		EventBus.room_cleared.emit(next_level_type)
		if NavManager:
			NavManager.go_to_level(next_level_path, next_level_spawnpoint)
	pass # Replace with function body.
