extends Node

enum room_types {COMBAT_ROOM, PEACEFUL_ROOM, CROSSROADS_ROOM, END_ROOM, NULL_ROOM}

var room_spawn_limit = {
	peaceful_room = 1,
	combat_room = 2,
	crossroads_room = 1,
}

func _ready() -> void:
	EventBus.connect("room_cleared", update_room_count)
	seed(12345)

# Finds what the next room type is and link it to a "door" in a level
func get_next_room_type():
	var rand = randf()
	if rand <= 0.333 and room_spawn_limit.peaceful_room > 0:
		return room_types.PEACEFUL_ROOM
	if rand <= 0.66 and room_spawn_limit.combat_room > 0:
		return room_types.COMBAT_ROOM
	if rand < 1 and room_spawn_limit.crossroads_room > 0:
		return room_types.CROSSROADS_ROOM
	# No more rooms to spawn!
	return room_types.END_ROOM

# Update the room count based on what room was taken
func update_room_count(room : MapGeneration.room_types) -> void:
	if room == room_types.PEACEFUL_ROOM:
		room_spawn_limit.peaceful_room -= 1
	elif room == room_types.COMBAT_ROOM:
		room_spawn_limit.combat_room -= 1
	elif room == room_types.CROSSROADS_ROOM:
		room_spawn_limit.crossroads_room -= 1
	pass

# Function to determine what type of rooms the next rooms should be, based on the number of doors or exit
# Returns an array containing: string containing the path to the room type scene, and type of next room
func generate_next_rooms() -> Dictionary:
	var out = {
		"path": "",
		"type": MapGeneration.room_types
	}
	
	var next_room_type = get_next_room_type()
	
	if next_room_type == MapGeneration.room_types.PEACEFUL_ROOM:
		out.path = "res://scenes/rooms/types/peaceful_room.tscn"
		out.type = MapGeneration.room_types.PEACEFUL_ROOM
	elif next_room_type == MapGeneration.room_types.COMBAT_ROOM:
		out.path = "res://scenes/rooms/types/combat_room.tscn"
		out.type = MapGeneration.room_types.COMBAT_ROOM
	elif next_room_type == MapGeneration.room_types.CROSSROADS_ROOM:
		out.path = "res://scenes/rooms/types/room_crossroads.tscn"
		out.type = MapGeneration.room_types.CROSSROADS_ROOM
	elif next_room_type == MapGeneration.room_types.END_ROOM:
		out.path = "res://scenes/rooms/types/end_room.tscn"
		out.type = MapGeneration.room_types.END_ROOM
	return out
