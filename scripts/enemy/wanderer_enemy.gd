extends EnemyBase
class_name WandererEnemy

func _ready() -> void:
	speed = 60.0
	contact_damage = 1
	_max_hp = 2
	super._ready()

func _create_visual() -> void:
	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([
		Vector2(-12, -12), Vector2(12, -12),
		Vector2(12, 12), Vector2(-12, 12),
	])
	visual.color = Color(0.6, 0.2, 0.2)
	visual.name = "Visual"
	add_child(visual)

func _create_state_machine() -> void:
	_build_state_machine([
		{
			node_name = "Wander",
			script = preload("res://scripts/enemy/states/enemy_wander_state.gd"),
		},
		{
			node_name = "Dead",
			script = preload("res://scripts/enemy/states/enemy_dead_state.gd"),
		},
	])
