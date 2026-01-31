extends Node2D
class_name Room

const ROOM_WIDTH := 960
const ROOM_HEIGHT := 540
const WALL_THICKNESS := 32
const DOOR_WIDTH := 96
const FLOOR_COLOR := Color(0.15, 0.15, 0.18)
const WALL_COLOR := Color(0.35, 0.3, 0.28)

const DOOR_POSITIONS := {
	Vector2i(0, -1): Vector2(480, 16),     # north
	Vector2i(0, 1):  Vector2(480, 524),     # south
	Vector2i(-1, 0): Vector2(16, 270),      # west
	Vector2i(1, 0):  Vector2(944, 270),     # east
}

const ENTRY_OFFSETS := {
	Vector2i(0, -1): Vector2(480, 60),
	Vector2i(0, 1):  Vector2(480, 480),
	Vector2i(-1, 0): Vector2(60, 270),
	Vector2i(1, 0):  Vector2(900, 270),
}

var room_id: int = -1
var enemy_count: int = 0
var is_cleared: bool = false
var active_doors: Array[Vector2i] = []
var doors: Dictionary = {}

var spawn_points: Array[Vector2] = []

func _ready() -> void:
	_create_floor()
	_create_walls()
	_create_doors()
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.room_cleared.connect(_on_room_cleared)

func setup(id: int, door_directions: Array[Vector2i], points: Array[Vector2], cleared: bool = false) -> void:
	room_id = id
	active_doors = door_directions
	spawn_points = points
	is_cleared = cleared

func _create_floor() -> void:
	var floor_rect := ColorRect.new()
	floor_rect.position = Vector2.ZERO
	floor_rect.size = Vector2(ROOM_WIDTH, ROOM_HEIGHT)
	floor_rect.color = FLOOR_COLOR
	floor_rect.z_index = -1
	add_child(floor_rect)

func _create_walls() -> void:
	var walls_node := Node2D.new()
	walls_node.name = "Walls"
	add_child(walls_node)

	var half_w := ROOM_WIDTH / 2.0
	var half_h := ROOM_HEIGHT / 2.0
	var half_door := DOOR_WIDTH / 2.0
	var t := float(WALL_THICKNESS)

	# Top wall (split for north door)
	_add_wall_segment(walls_node, Rect2(0, 0, half_w - half_door, t))
	_add_wall_segment(walls_node, Rect2(half_w + half_door, 0, half_w - half_door, t))

	# Bottom wall (split for south door)
	_add_wall_segment(walls_node, Rect2(0, ROOM_HEIGHT - t, half_w - half_door, t))
	_add_wall_segment(walls_node, Rect2(half_w + half_door, ROOM_HEIGHT - t, half_w - half_door, t))

	# Left wall (split for west door)
	_add_wall_segment(walls_node, Rect2(0, t, t, half_h - half_door - t))
	_add_wall_segment(walls_node, Rect2(0, half_h + half_door, t, half_h - half_door - t))

	# Right wall (split for east door)
	_add_wall_segment(walls_node, Rect2(ROOM_WIDTH - t, t, t, half_h - half_door - t))
	_add_wall_segment(walls_node, Rect2(ROOM_WIDTH - t, half_h + half_door, t, half_h - half_door - t))

func _add_wall_segment(parent: Node, rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = rect.position + rect.size / 2.0
	body.collision_layer = 1
	body.collision_mask = 0
	parent.add_child(body)

	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var col := CollisionShape2D.new()
	col.shape = shape
	body.add_child(col)

	var visual := ColorRect.new()
	visual.size = rect.size
	visual.position = -rect.size / 2.0
	visual.color = WALL_COLOR
	body.add_child(visual)

func _create_doors() -> void:
	var doors_node := Node2D.new()
	doors_node.name = "Doors"
	add_child(doors_node)

	for dir in DOOR_POSITIONS:
		var door := Door.new()
		door.direction = dir
		door.position = DOOR_POSITIONS[dir]
		doors_node.add_child(door)
		doors[dir] = door

		if dir in active_doors:
			if is_cleared:
				door.open()
			else:
				door.close()
		else:
			door.hide_door()

func lock_doors() -> void:
	for dir in doors:
		if dir in active_doors:
			doors[dir].close()

func unlock_doors() -> void:
	for dir in doors:
		if dir in active_doors:
			doors[dir].open()

func register_enemy() -> void:
	enemy_count += 1

func _on_enemy_died(_pos: Vector2) -> void:
	enemy_count -= 1
	if enemy_count <= 0 and not is_cleared:
		is_cleared = true
		GameData.mark_room_cleared(room_id)
		EventBus.room_cleared.emit()

func _on_room_cleared() -> void:
	unlock_doors()

func get_room_center() -> Vector2:
	return Vector2(ROOM_WIDTH / 2.0, ROOM_HEIGHT / 2.0)

static func get_entry_position(from_direction: Vector2i) -> Vector2:
	var opposite := -from_direction
	if ENTRY_OFFSETS.has(opposite):
		return ENTRY_OFFSETS[opposite]
	return Vector2(ROOM_WIDTH / 2.0, ROOM_HEIGHT / 2.0)
