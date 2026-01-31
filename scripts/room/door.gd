extends Node2D
class_name Door

const DOOR_SIZE := Vector2(96, 32)
const CLOSED_COLOR := Color(0.5, 0.15, 0.15)
const OPEN_COLOR := Color(0.2, 0.5, 0.2)

var direction: Vector2i = Vector2i.ZERO
var is_open: bool = false

var _block_body: StaticBody2D
var _trigger_area: Area2D
var _visual: ColorRect

func _ready() -> void:
	_create_block()
	_create_trigger()
	_create_visual()
	close()

func _create_block() -> void:
	_block_body = StaticBody2D.new()
	_block_body.collision_layer = 1
	_block_body.collision_mask = 0

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = _get_door_size()
	col.shape = shape
	_block_body.add_child(col)
	add_child(_block_body)

func _create_trigger() -> void:
	_trigger_area = Area2D.new()
	_trigger_area.collision_layer = 64  # doors layer 7
	_trigger_area.collision_mask = 2    # player layer 2
	_trigger_area.monitoring = true
	_trigger_area.monitorable = false

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = _get_door_size() + Vector2(8, 8)
	col.shape = shape
	_trigger_area.add_child(col)
	add_child(_trigger_area)

	_trigger_area.body_entered.connect(_on_body_entered)

func _create_visual() -> void:
	var size := _get_door_size()
	_visual = ColorRect.new()
	_visual.size = size
	_visual.position = -size / 2.0
	add_child(_visual)

func _get_door_size() -> Vector2:
	if direction.x != 0:
		return Vector2(DOOR_SIZE.y, DOOR_SIZE.x)
	return DOOR_SIZE

func open() -> void:
	is_open = true
	_block_body.collision_layer = 0
	_visual.color = OPEN_COLOR

func close() -> void:
	is_open = false
	_block_body.collision_layer = 1
	_visual.color = CLOSED_COLOR

func hide_door() -> void:
	# Keep blocking the gap (acts as wall), but no visual or trigger
	_visual.color = Color(0.35, 0.3, 0.28)  # match wall color
	_block_body.collision_layer = 1
	_trigger_area.monitoring = false

func _on_body_entered(body: Node2D) -> void:
	if is_open and body.is_in_group("player"):
		EventBus.player_entered_door.emit(direction)
