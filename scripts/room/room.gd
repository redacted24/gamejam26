extends Node2D
class_name Room

func _ready() -> void:
	print("Loading a room")
	if NavManager.spawn_location != null:
		_on_level_spawn(NavManager.spawn_location)
		
func _on_level_spawn(spawn_location : String) -> void:
	var spawn_path = "SpawnPoints/" + spawn_location
	var spawn : Node2D = get_node(spawn_path)
	NavManager.trigger_player_spawn(spawn.global_position)

var enemy_count: int = 0
var is_cleared: bool = false

#
#func lock_doors() -> void:
	#for dir in doors:
		#if dir in active_doors:
			#doors[dir].close()
#
#func unlock_doors() -> void:
	#for dir in doors:
		#if dir in active_doors:
			#doors[dir].open()
