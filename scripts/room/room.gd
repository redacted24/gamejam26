extends Node2D
class_name Room

@export var room_type : MapGeneration.room_types
var enemy_count : int
var door_count : int
var is_cleared : bool
var all_doors : Array # array holds all doors (exits)

func _ready() -> void:
	is_cleared = false
	# Connect spawn location signal
	if NavManager and NavManager.spawn_location != null:
		_on_level_spawn(NavManager.spawn_location)
	
	# Get all door nodes
	all_doors = get_node("Doors").get_children()
	door_count = all_doors.size()
	
	# iterate through doors and assign their teleport
	for door : Door in all_doors:
		var next_room = generate_next_rooms()
		# [0] is path, [1] is room type
		door.next_level_path = next_room[0]
		door.next_level_type = next_room[1]
		# all rooms should only have one spawnpoint for now
		door.next_level_spawnpoint = "Main"
		print("a door connects to %s" % next_room[0])
		
func spawn_enemies() -> void:
	pass
	
# Function to determine what type of rooms the next rooms should be, based on the number of doors or exit
# Returns an array containing: string containing the path to the room type scene, and type of next room
func generate_next_rooms() -> Array:
	var out : Array
	var next_room_type = MapGeneration.next_room_type()
	if next_room_type == MapGeneration.room_types.PEACEFUL_ROOM:
		out.append("res://scenes/rooms/types/peaceful_room.tscn")
		out.append(MapGeneration.room_types.PEACEFUL_ROOM)
	elif next_room_type == MapGeneration.room_types.COMBAT_ROOM:
		out.append("res://scenes/rooms/types/combat_room.tscn")
		out.append(MapGeneration.room_types.COMBAT_ROOM)
	elif next_room_type == MapGeneration.room_types.CROSSROADS_ROOM:
		out.append("res://scenes/rooms/types/room_crossroads.tscn")
		out.append(MapGeneration.room_types.CROSSROADS_ROOM)
	elif next_room_type == MapGeneration.room_types.END_ROOM:
		out.append("res://scenes/rooms/types/end_room.tscn")
		out.append(MapGeneration.room_types.END_ROOM)
	return out
	
# Function that determines where the player should spawn
# Emits the signal for the player to spawn
func _on_level_spawn(spawn_location : String) -> void:
	var spawn_path = "SpawnPoints/" + spawn_location
	var spawn : Node2D = get_node(spawn_path)
	NavManager.trigger_player_spawn(spawn.global_position)
