extends EnemyBase
class_name DasherEnemy

func _ready() -> void:
	speed = 50.0
	contact_damage = 1
	_max_hp = 2
	super._ready()

func _create_visual() -> void:
	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([
		Vector2(0, -18), Vector2(12, 10),
		Vector2(-12, 10),
	])
	visual.color = Color(0.9, 0.85, 0.1)
	visual.name = "Visual"
	add_child(visual)

func _create_state_machine() -> void:
	_build_state_machine([
		{
			node_name = "Idle",
			script = preload("res://scripts/enemy/states/enemy_idle_state.gd"),
			props = { next_state_name = "dash", idle_duration = 1.5 },
		},
		{
			node_name = "Dash",
			script = preload("res://scripts/enemy/states/enemy_dash_state.gd"),
		},
		{
			node_name = "Dead",
			script = preload("res://scripts/enemy/states/enemy_dead_state.gd"),
		},
	])
