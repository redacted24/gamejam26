extends Node

# There will be 15 total "rooms" to go through.
var stages_count = 15
var current_stage = 0

enum room_types {
	COMBAT_ROOM, 
	PEACEFUL_ROOM, 
	CROSSROADS_ROOM, 
	TUTORIAL_ROOM,
	BOSS_ROOM,
	SHOP_ROOM,
	FOX_ROOM,
	END_ROOM,
	CUTSCENE_ROOM, 
	NULL_ROOM
}

# Room types depending on current stage
const stage_types = {
	0: room_types.CUTSCENE_ROOM,
	1: room_types.TUTORIAL_ROOM,
	2: room_types.COMBAT_ROOM,
	3: room_types.COMBAT_ROOM,
	4: room_types.PEACEFUL_ROOM,
	5: room_types.CROSSROADS_ROOM,
	6: room_types.SHOP_ROOM,
	7: room_types.COMBAT_ROOM,
	8: room_types.FOX_ROOM,
	9: room_types.CROSSROADS_ROOM,
	10: room_types.COMBAT_ROOM,
	11: room_types.COMBAT_ROOM,
	12: room_types.COMBAT_ROOM,
	13: room_types.PEACEFUL_ROOM,
	14: room_types.SHOP_ROOM,
	15: room_types.BOSS_ROOM,
	16: room_types.END_ROOM
}

# All variations of combat rooms
const COMBAT_ROOM_PATHS = [
	"res://scenes/rooms/types/combat/combat_room_1.tscn",
	"res://scenes/rooms/types/combat/combat_room_2.tscn",
]

# All variation of peaceful rooms
const PEACEFUL_ROOM_PATHS = [
	"res://scenes/rooms/types/neutral/neutral_room_1.tscn",
]

# All variations of crossroads rooms
const CROSSROADS_ROOM_PATHS = [
	"res://scenes/rooms/types/crossroads/crossroads_1.tscn",
	"res://scenes/rooms/types/crossroads/crossroads_2.tscn",
]

func _ready() -> void:
	seed(12345)

# Function to determine what type of rooms the next rooms should be, based on the number of doors or exit
# Returns an array containing: string containing the path to the room type scene, and type of next room
func generate_next_rooms() -> Dictionary:
	var out = {
		"path": "",
		"type": MapGeneration.room_types
	}
	
	var next_room_type : MapGeneration.room_types = stage_types[0]
	var num_that_type : int
	var rand_idx : int
	
	if next_room_type == MapGeneration.room_types.PEACEFUL_ROOM:
		num_that_type = PEACEFUL_ROOM_PATHS.size()
		rand_idx = randi() % num_that_type
		out.path = PEACEFUL_ROOM_PATHS[rand_idx]
		out.type = MapGeneration.room_types.PEACEFUL_ROOM
	elif next_room_type == MapGeneration.room_types.COMBAT_ROOM:
		num_that_type = COMBAT_ROOM_PATHS.size()
		rand_idx = randi() % num_that_type
		out.path = COMBAT_ROOM_PATHS[rand_idx]
		out.type = MapGeneration.room_types.COMBAT_ROOM
	elif next_room_type == MapGeneration.room_types.CROSSROADS_ROOM:
		num_that_type = CROSSROADS_ROOM_PATHS.size()
		rand_idx = randi() % num_that_type
		out.path = CROSSROADS_ROOM_PATHS[rand_idx]
		out.type = MapGeneration.room_types.CROSSROADS_ROOM
	elif next_room_type == MapGeneration.room_types.END_ROOM:
		out.path = "res://scenes/rooms/types/end_room.tscn"
		out.type = MapGeneration.room_types.END_ROOM
	return out
