extends Node2D
class_name Room

const ROOM_SIZE := Vector2(960, 540)
const WALL_THICKNESS := 16.0
const DOOR_WIDTH := 64.0

var room_id: int = 0
var spawn_points: Array[Vector2] = []
var enemy_count: int = 0
var is_cleared: bool = false

var _door_dirs: Array[Vector2i] = []
var _door_nodes: Array = []

func setup(id: int, door_dirs: Array[Vector2i], spawn_pts: Array[Vector2], already_cleared: bool) -> void:
	room_id = id
	_door_dirs = door_dirs
	spawn_points = spawn_pts
	is_cleared = already_cleared

	_create_floor()
	_create_walls()
	_create_doors()

func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)

func get_room_center() -> Vector2:
	return ROOM_SIZE / 2.0

static func get_entry_position(direction: Vector2i) -> Vector2:
	# direction = the way the player walked to get here
	# entry position = near the opposite door
	match direction:
		Vector2i(0, -1):  # went north -> enter from south
			return Vector2(480, 480)
		Vector2i(0, 1):   # went south -> enter from north
			return Vector2(480, 60)
		Vector2i(-1, 0):  # went west -> enter from east
			return Vector2(900, 270)
		Vector2i(1, 0):   # went east -> enter from west
			return Vector2(60, 270)
	return Vector2(480, 270)

func register_enemy() -> void:
	enemy_count += 1

func unlock_doors() -> void:
	for door in _door_nodes:
		door.open()

func _on_enemy_died(_pos: Vector2) -> void:
	enemy_count -= 1
	if enemy_count <= 0:
		enemy_count = 0
		is_cleared = true
		unlock_doors()
		GameData.mark_room_cleared(room_id)
		EventBus.room_cleared.emit(MapGeneration.room_types.COMBAT_ROOM)

# -- Room construction -------------------------------------------------------

func _create_floor() -> void:
	var floor_rect := ColorRect.new()
	floor_rect.size = ROOM_SIZE
	floor_rect.color = Color(0.12, 0.12, 0.15)
	add_child(floor_rect)

func _create_walls() -> void:
	var walls_body := StaticBody2D.new()
	walls_body.collision_layer = 1
	add_child(walls_body)

	var walls_visual := Node2D.new()
	add_child(walls_visual)

	for side in ["north", "south", "west", "east"]:
		var dir := _side_to_direction(side)
		var has_door := dir in _door_dirs
		_build_wall(walls_body, walls_visual, side, has_door)

func _build_wall(body: StaticBody2D, visual_parent: Node2D, side: String, has_door: bool) -> void:
	var w := ROOM_SIZE.x
	var h := ROOM_SIZE.y
	var t := WALL_THICKNESS
	var gap := DOOR_WIDTH

	if not has_door:
		match side:
			"north": _add_wall_piece(body, visual_parent, Vector2(w / 2, t / 2), Vector2(w, t))
			"south": _add_wall_piece(body, visual_parent, Vector2(w / 2, h - t / 2), Vector2(w, t))
			"west":  _add_wall_piece(body, visual_parent, Vector2(t / 2, h / 2), Vector2(t, h))
			"east":  _add_wall_piece(body, visual_parent, Vector2(w - t / 2, h / 2), Vector2(t, h))
	else:
		var half: float
		match side:
			"north":
				half = (w - gap) / 2.0
				_add_wall_piece(body, visual_parent, Vector2(half / 2, t / 2), Vector2(half, t))
				_add_wall_piece(body, visual_parent, Vector2(w - half / 2, t / 2), Vector2(half, t))
			"south":
				half = (w - gap) / 2.0
				_add_wall_piece(body, visual_parent, Vector2(half / 2, h - t / 2), Vector2(half, t))
				_add_wall_piece(body, visual_parent, Vector2(w - half / 2, h - t / 2), Vector2(half, t))
			"west":
				half = (h - gap) / 2.0
				_add_wall_piece(body, visual_parent, Vector2(t / 2, half / 2), Vector2(t, half))
				_add_wall_piece(body, visual_parent, Vector2(t / 2, h - half / 2), Vector2(t, half))
			"east":
				half = (h - gap) / 2.0
				_add_wall_piece(body, visual_parent, Vector2(w - t / 2, half / 2), Vector2(t, half))
				_add_wall_piece(body, visual_parent, Vector2(w - t / 2, h - half / 2), Vector2(t, half))

func _add_wall_piece(body: StaticBody2D, visual_parent: Node2D, pos: Vector2, size: Vector2) -> void:
	var shape := RectangleShape2D.new()
	shape.size = size
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = pos
	body.add_child(col)

	var rect := ColorRect.new()
	rect.size = size
	rect.position = pos - size / 2.0
	rect.color = Color(0.25, 0.22, 0.2)
	visual_parent.add_child(rect)

func _create_doors() -> void:
	for dir in _door_dirs:
		var door := Door.new()
		door.direction = dir

		match dir:
			Vector2i(0, -1):  # North
				door.position = Vector2(ROOM_SIZE.x / 2, WALL_THICKNESS / 2)
				door._door_size = Vector2(DOOR_WIDTH, WALL_THICKNESS)
			Vector2i(0, 1):   # South
				door.position = Vector2(ROOM_SIZE.x / 2, ROOM_SIZE.y - WALL_THICKNESS / 2)
				door._door_size = Vector2(DOOR_WIDTH, WALL_THICKNESS)
			Vector2i(-1, 0):  # West
				door.position = Vector2(WALL_THICKNESS / 2, ROOM_SIZE.y / 2)
				door._door_size = Vector2(WALL_THICKNESS, DOOR_WIDTH)
			Vector2i(1, 0):   # East
				door.position = Vector2(ROOM_SIZE.x - WALL_THICKNESS / 2, ROOM_SIZE.y / 2)
				door._door_size = Vector2(WALL_THICKNESS, DOOR_WIDTH)

		door.is_open = is_cleared
		add_child(door)
		_door_nodes.append(door)

func _side_to_direction(side: String) -> Vector2i:
	match side:
		"north": return Vector2i(0, -1)
		"south": return Vector2i(0, 1)
		"west":  return Vector2i(-1, 0)
		"east":  return Vector2i(1, 0)
	return Vector2i.ZERO
