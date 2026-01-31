extends Node

var types = [PeacefulRoom, CombatRoom, HomeRoom, CrossroadsRoom, RatsRoom]

var room_spawn_limit = {
	peaceful_room = 1,
	combat_room = 2,
	crossroads_room = 1,
	rats_room = 1
}

func _ready() -> void:
	seed(12345)

# Finds what the next room type is and link it to a "door" in a level
func next_room_type():
	var rand = randf()
	# Land on peaceful room
	if rand <= 0.25 and room_spawn_limit.peaceful_room > 0:
		return PeacefulRoom
	elif rand <= 0.5 and room_spawn_limit.combat_room > 0:
		return CombatRoom
	elif rand <= 0.75 and room_spawn_limit.crossroads_room > 0:
		return CrossroadsRoom
	elif rand < 1 and room_spawn_limit.rats_room > 0:
		return RatsRoom
	pass

# Update the room count based on what room was taken
func update_room_count(room) -> void:
	if room == PeacefulRoom:
		room_spawn_limit.peaceful_room -= 1
	elif room == CombatRoom:
		room_spawn_limit.combat_room -= 1
	elif room == CrossroadsRoom:
		room_spawn_limit.crossroads_room -= 1
	elif room == RatsRoom:
		room_spawn_limit.rats_room -= 1
	pass
