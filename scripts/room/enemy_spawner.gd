extends RefCounted
class_name EnemySpawner

const ENEMY_TYPES: Array = [
	preload("res://scenes/enemies/chase_enemy.tscn"),
]

static func spawn_enemies(room: Room, parent: Node) -> int:
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
