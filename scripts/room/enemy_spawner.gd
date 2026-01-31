extends RefCounted
class_name EnemySpawner

const ENEMY_TYPES: Array = [
	preload("res://scenes/enemies/rat_enemy.tscn"),
]

static func spawn_enemies(room: Room, parent: Node) -> int:
	# Only host spawns enemies in multiplayer
	if NetworkManager.is_online() and not parent.multiplayer.is_server():
		return 0

	var count := 0
	for point in room.spawn_points:
		var entry = ENEMY_TYPES.pick_random()
		var enemy: CharacterBody2D
		if entry is PackedScene:
			enemy = entry.instantiate()
		else:
			enemy = CharacterBody2D.new()
			enemy.set_script(entry)
		enemy.position = point
		parent.add_child(enemy)
		room.register_enemy()
		count += 1
	return count
