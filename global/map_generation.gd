extends Node
class_name MapGeneration

var types = [PeacefulRoom, CombatRoom, HomeRoom, CrossroadsRoom]

var room_spawn_limit = {
	peaceful_room = 1,
	combat_room = 2,
	crossroads_room = 1
}

# Finds what the next room type is and link it to a "door" in a level
func next_room_type() -> void:
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
