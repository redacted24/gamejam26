extends EnemyBase
class_name ShooterEnemy

func _ready() -> void:
	speed = 0.0
	contact_damage = 1
	_max_hp = 2
	super._ready()

func _create_visual() -> void:
	var visual := Polygon2D.new()
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(6):
		var angle := i * TAU / 6.0 - PI / 2.0
		points.append(Vector2(cos(angle), sin(angle)) * 14.0)
	visual.polygon = points
	visual.color = Color(0.5, 0.2, 0.7)
	visual.name = "Visual"
	add_child(visual)
