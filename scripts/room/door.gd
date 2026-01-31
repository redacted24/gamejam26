extends Node2D
class_name Door

var direction: Vector2i = Vector2i.ZERO
var is_open: bool = false
var _door_size: Vector2 = Vector2(64, 16)

var _block_body: StaticBody2D
var _visual: ColorRect

const CLOSED_COLOR := Color(0.5, 0.3, 0.2)
const OPEN_COLOR := Color(0.2, 0.7, 0.3)

func _ready() -> void:
	# Blocking collision (prevents passage when closed)
	_block_body = StaticBody2D.new()
	_block_body.collision_layer = 1
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = _door_size
	col.shape = shape
	_block_body.add_child(col)
	add_child(_block_body)

	# Detection area (triggers room transition when open)
	var area := Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 2  # player layer
	area.monitoring = true
	area.monitorable = false
	var area_col := CollisionShape2D.new()
	var area_shape := RectangleShape2D.new()
	area_shape.size = _door_size + Vector2(8, 8)
	area_col.shape = area_shape
	area.add_child(area_col)
	area.body_entered.connect(_on_body_entered)
	add_child(area)

	# Visual
	_visual = ColorRect.new()
	_visual.size = _door_size
	_visual.position = -_door_size / 2.0
	add_child(_visual)

	_update_state()

func open() -> void:
	is_open = true
	if is_inside_tree():
		_update_state()

func close() -> void:
	is_open = false
	if is_inside_tree():
		_update_state()

func _update_state() -> void:
	if _block_body:
		_block_body.collision_layer = 0 if is_open else 1
	if _visual:
		_visual.color = OPEN_COLOR if is_open else CLOSED_COLOR

func _on_body_entered(body: Node2D) -> void:
	if is_open and body.is_in_group("player"):
		EventBus.player_entered_door.emit(direction)
