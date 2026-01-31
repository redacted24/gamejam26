extends Node2D
class_name Room

func _ready() -> void:
	print("Loading new room")
	if NavManager and NavManager.spawn_location != null:
		_on_level_spawn(NavManager.spawn_location)
		
func _on_level_spawn(spawn_location : String) -> void:
	var spawn_path = "SpawnPoints/" + spawn_location
	var spawn : Node2D = get_node(spawn_path)
	NavManager.trigger_player_spawn(spawn.global_position)

var enemy_count: int = 0
var is_cleared: bool = false
