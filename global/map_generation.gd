extends Node

enum room_types {COMBAT_ROOM, PEACEFUL_ROOM, CROSSROADS_ROOM, END_ROOM}

var room_spawn_limit = {
	peaceful_room = 1,
	combat_room = 2,
	crossroads_room = 1,
}

func _ready() -> void:
	seed(12345)

# Finds what the next room type is and link it to a "door" in a level
func next_room_type():
	print(room_spawn_limit)
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
func update_room_count(room) -> void:
	if room == room_types.PEACEFUL_ROOM:
		room_spawn_limit.peaceful_room -= 1
	elif room == room_types.COMBAT_ROOM:
		room_spawn_limit.combat_room -= 1
	elif room == room_types.CROSSROADS_ROOM:
		room_spawn_limit.crossroads_room -= 1
	pass
