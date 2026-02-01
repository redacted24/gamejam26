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
var stage_types = [
	room_types.CUTSCENE_ROOM,
	room_types.TUTORIAL_ROOM,
	room_types.COMBAT_ROOM,
	room_types.COMBAT_ROOM,
	room_types.PEACEFUL_ROOM,
	room_types.CROSSROADS_ROOM,
	room_types.SHOP_ROOM,
	room_types.COMBAT_ROOM,
	room_types.FOX_ROOM,
	room_types.CROSSROADS_ROOM,
	room_types.COMBAT_ROOM,
	room_types.COMBAT_ROOM,
	room_types.COMBAT_ROOM,
	room_types.PEACEFUL_ROOM,
	room_types.SHOP_ROOM,
	room_types.BOSS_ROOM,
	room_types.END_ROOM
]

# All variations of combat rooms

const TUTORIAL_ROOM_PATHS = [
	"res://scenes/rooms/types/tutorial/tutorial_room.tscn"
]
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

# All variations of shop rooms
const SHOP_ROOM_PATHS = [
	"res://scenes/rooms/types/shop/shop.tscn"
]

# All variations of boss rooms
const BOSS_ROOM_PATHS = [
	"res://scenes/rooms/types/boss/boss.tscn"
]

# All variations of end rooms
const END_ROOM_PATHS = [
	"res://scenes/rooms/types/end_room.tscn"
]

# All variations of fox rooms
const FOX_ROOM_PATHS = [
	"res://scenes/rooms/types/fox/fox.tscn"
]

func _ready() -> void:
	seed(12345)

# Function to determine what type of rooms the next rooms should be, based on the number of doors or exit
# Returns an array containing: string containing the path to the room type scene, and type of next room
func generate_next_rooms() -> Dictionary:
	var out = {
		"path": "",
		"type": null
	}
	
	current_stage += 1
	var next_room_type : room_types = stage_types[current_stage]
	var num_that_type : int
	var rand_idx : int
	
	# Match next room type and get the proper resource for it
	var en = room_types
	if next_room_type == en.PEACEFUL_ROOM:
		num_that_type = PEACEFUL_ROOM_PATHS.size()
		rand_idx = randi() % num_that_type
		out.path = PEACEFUL_ROOM_PATHS[rand_idx]
		out.type = en.PEACEFUL_ROOM
	elif next_room_type == en.COMBAT_ROOM:
		num_that_type = COMBAT_ROOM_PATHS.size()
		rand_idx = randi() % num_that_type
		out.path = COMBAT_ROOM_PATHS[rand_idx]
		out.type = en.COMBAT_ROOM
	elif next_room_type == en.TUTORIAL_ROOM:
		out.path = TUTORIAL_ROOM_PATHS[0]
		out.type = en.TUTORIAL_ROOM
	elif next_room_type == en.CROSSROADS_ROOM:
		num_that_type = CROSSROADS_ROOM_PATHS.size()
		rand_idx = randi() % num_that_type
		out.path = CROSSROADS_ROOM_PATHS[rand_idx]
		out.type = en.CROSSROADS_ROOM
	elif next_room_type == en.SHOP_ROOM:
		out.path = SHOP_ROOM_PATHS[0]
		out.type = en.SHOP_ROOM
	elif next_room_type == en.BOSS_ROOM:
		out.path = BOSS_ROOM_PATHS[0]
		out.type = en.BOSS_ROOM
	elif next_room_type == en.FOX_ROOM:
		out.path = FOX_ROOM_PATHS[0]
		out.type = en.FOX_ROOM
	elif next_room_type == en.END_ROOM:
		out.path = END_ROOM_PATHS[0]
		out.type = en.END_ROOM

	return out
