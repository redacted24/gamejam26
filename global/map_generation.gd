extends Node

enum room_types {COMBAT_ROOM, PEACEFUL_ROOM, CROSSROADS_ROOM}

var room_spawn_limit = {
	peaceful_room = 1,
	combat_room = 2,
	crossroads_room = 1
}

func _ready() -> void:
	seed(12345)

# Finds what the next room type is and link it to a "door" in a level
func next_room_type():
	var rand = randf()
	# Land on peaceful room
	if rand <= 0.333 and room_spawn_limit.peaceful_room > 0:
		return room_types.PEACEFUL_ROOM
	elif rand <= 0.66 and room_spawn_limit.combat_room > 0:
		return room_types.COMBAT_ROOM
	elif rand < 1 and room_spawn_limit.crossroads_room > 0:
		return room_types.CROSSROADS_ROOM
	pass

# Update the room count based on what room was taken
func update_room_count(room) -> void:
	if room is PeacefulRoom:
		room_spawn_limit.peaceful_room -= 1
	elif room is CombatRoom:
		room_spawn_limit.combat_room -= 1
	elif room is CrossroadsRoom:
		room_spawn_limit.crossroads_room -= 1
	pass
