extends EnemyBase
class_name ChaseEnemy

func _ready() -> void:
	speed = 80.0
	contact_damage = 1
	_max_hp = 3
	super._ready()

func _create_visual() -> void:
	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([
		Vector2(0, -16), Vector2(14, 8),
		Vector2(0, 4), Vector2(-14, 8),
	])
	visual.color = Color(0.9, 0.5, 0.1)
	visual.name = "Visual"
	add_child(visual)
