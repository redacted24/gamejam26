extends Node2D
class_name Room

var enemy_count : int
var door_count : int
var is_cleared : bool

func _ready() -> void:
	is_cleared = false
	print("Loading new room")
	if NavManager and NavManager.spawn_location != null:
		_on_level_spawn(NavManager.spawn_location)

func spawn_enemies() -> void:
	pass
	
# Function to determine what type of rooms the next rooms should be, based on the number of doors or exit
# Returns a string containing the path to the room type scene yay
func generate_next_rooms() -> String:
	var next_room_type = MapGeneration.next_room_type()
	if next_room_type is PeacefulRoom:
		return "res://scenes/rooms/types/peaceful_room.tscn"
	elif next_room_type is CombatRoom:
		return "res://scenes/rooms/types/combat_room.tscn"
	elif next_room_type is CrossroadsRoom:
		return "res://scenes/rooms/types/room_crossroads.tscn"
	return ""
	
# Function that determines where the player should spawn
# Emits the signal for the player to spawn
func _on_level_spawn(spawn_location : String) -> void:
	var spawn_path = "SpawnPoints/" + spawn_location
	var spawn : Node2D = get_node(spawn_path)
	NavManager.trigger_player_spawn(spawn.global_position)
