extends Node2D
class_name Room

const ROOM_WIDTH: float = 960.0
const ROOM_HEIGHT: float = 540.0

var room_id: int = -1
var enemy_count: int = 0
var is_cleared: bool = false
var active_doors: Array[Vector2i] = []
var doors: Dictionary = {}
var spawn_points: Array[Vector2] = []

func _ready() -> void:
	pass

func setup(id: int, door_directions: Array[Vector2i], points: Array[Vector2], cleared: bool = false) -> void:
	room_id = id
	active_doors = door_directions
	spawn_points = points
	is_cleared = cleared

func get_room_center() -> Vector2:
	return Vector2(ROOM_WIDTH / 2.0, ROOM_HEIGHT / 2.0)

static func get_entry_position(entry_direction: Vector2i) -> Vector2:
	var center := Vector2(ROOM_WIDTH / 2.0, ROOM_HEIGHT / 2.0)
	var offset := 100.0
	match entry_direction:
		Vector2i.UP:
			return Vector2(center.x, ROOM_HEIGHT - offset)
		Vector2i.DOWN:
			return Vector2(center.x, offset)
		Vector2i.LEFT:
			return Vector2(ROOM_WIDTH - offset, center.y)
		Vector2i.RIGHT:
			return Vector2(offset, center.y)
	return center

func lock_doors() -> void:
	for dir in doors:
		if dir in active_doors:
			doors[dir].close()

func unlock_doors() -> void:
	for dir in doors:
		if dir in active_doors:
			doors[dir].open()
