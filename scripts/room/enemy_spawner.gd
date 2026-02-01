extends RefCounted
class_name EnemySpawner

const ENEMY_TYPES: Array = [
	preload("res://scenes/enemies/rat_enemy.tscn"),
]

static func spawn_enemies(room: Room, parent: Node) -> int:
	# Use seeded RNG so host and client pick the same enemy types
	var rng := RandomNumberGenerator.new()
	rng.seed = room.room_id * 73856093

	var count := 0
	for point in room.spawn_points:
		var type_idx := rng.randi() % ENEMY_TYPES.size()
		var entry = ENEMY_TYPES[type_idx]
		var enemy: CharacterBody2D
		if entry is PackedScene:
			enemy = entry.instantiate()
		else:
			enemy = CharacterBody2D.new()
			enemy.set_script(entry)
		enemy.name = "Enemy_%d" % count
		enemy.position = point
		parent.add_child(enemy)
		room.register_enemy()
		count += 1
	return count
