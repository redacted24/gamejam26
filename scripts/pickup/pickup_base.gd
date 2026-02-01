extends Area2D
class_name Pickup

var pickup_type: String = "health"
var value: float = 1.0
var _visual_color: Color = Color.RED
var _visual_points: PackedVector2Array = PackedVector2Array()
var _visual_texture: Texture2D = null
var _visual_scale: float = 1.0
var attract_radius: float = 0.0
var attract_speed: float = 200.0

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
	var visual: Node2D
	if _visual_texture:
		var sprite := Sprite2D.new()
		sprite.texture = _visual_texture
		sprite.scale = Vector2(_visual_scale, _visual_scale)
		visual = sprite
	else:
		var poly := Polygon2D.new()
		if _visual_points.size() > 0:
			poly.polygon = _visual_points
		else:
			poly.polygon = PackedVector2Array([
				Vector2(-8, -8), Vector2(8, -8),
				Vector2(8, 8), Vector2(-8, 8),
			])
		poly.color = _visual_color
		visual = poly
	add_child(visual)

	# Floating animation
	var tween := create_tween().set_loops()
	tween.tween_property(visual, "position:y", -4.0, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(visual, "position:y", 4.0, 0.5).set_trans(Tween.TRANS_SINE)

func _process(delta: float) -> void:
	if attract_radius <= 0.0:
		return
	var players := get_tree().get_nodes_in_group("player")
	for p: Node2D in players:
		var dist := global_position.distance_to(p.global_position)
		if dist < attract_radius and dist > 0.0:
			var dir: Vector2 = (p.global_position - global_position).normalized()
			global_position += dir * attract_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body is Player:
		body.apply_pickup(pickup_type, value)
		_check_post_tutorial_dialogue()
		queue_free()

func _check_post_tutorial_dialogue() -> void:
	if pickup_type == "food" and not PlayerData.post_tutorial_shown:
		PlayerData.post_tutorial_shown = true
		var resource: DialogueResource = load("res://dialogues/3_post_tutorial.dialogue")
		var balloon: Node = load("res://scenes/dialogue/balloon.tscn").instantiate()
		get_tree().current_scene.add_child(balloon)
		DialogueManager.show_dialogue_balloon_scene(balloon, resource, "start")
