extends Area2D
class_name Pickup

var pickup_type: String = "health"
var value: float = 1.0
var _visual_color: Color = Color.RED
var _visual_points: PackedVector2Array = PackedVector2Array()

func _ready() -> void:
	collision_layer = 32  # pickups layer 6
	collision_mask = 2    # player layer 2
	monitoring = true
	monitorable = false

	_create_collision()
	_create_visual()
	body_entered.connect(_on_body_entered)

func setup(type: String, val: float, color: Color, points: PackedVector2Array) -> void:
	pickup_type = type
	value = val
	_visual_color = color
	_visual_points = points

func _create_collision() -> void:
	var col := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 10.0
	col.shape = circle
	add_child(col)

func _create_visual() -> void:
	var visual := Polygon2D.new()
	if _visual_points.size() > 0:
		visual.polygon = _visual_points
	else:
		visual.polygon = PackedVector2Array([
			Vector2(-8, -8), Vector2(8, -8),
			Vector2(8, 8), Vector2(-8, 8),
		])
	visual.color = _visual_color
	add_child(visual)

	# Floating animation
	var tween := create_tween().set_loops()
	tween.tween_property(visual, "position:y", -4.0, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(visual, "position:y", 4.0, 0.5).set_trans(Tween.TRANS_SINE)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body is Player:
		body.apply_pickup(pickup_type, value)
		queue_free()
