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
