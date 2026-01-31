extends RefCounted
class_name EnemySpawner

const ENEMY_TYPES: Array[Script] = [
	preload("res://scripts/enemy/wanderer_enemy.gd"),
	preload("res://scripts/enemy/chase_enemy.gd"),
	preload("res://scripts/enemy/shooter_enemy.gd"),
	preload("res://scripts/enemy/dasher_enemy.gd"),
]

static func spawn_enemies(room: Room, parent: Node) -> int:
	var count := 0
	for point in room.spawn_points:
		var enemy_script: Script = ENEMY_TYPES.pick_random()
		var enemy := CharacterBody2D.new()
		enemy.set_script(enemy_script)
		enemy.position = point
		parent.add_child(enemy)
		room.register_enemy()
		count += 1
	return count
