extends Control

var floor_data: Dictionary = {}
var current_room_id: int = -1
var visited_rooms: Array[int] = []

const CELL_SIZE := 14
const CELL_GAP := 2
const OFFSET := Vector2(60, 60)

func _ready() -> void:
	EventBus.room_entered.connect(_on_room_entered)

func set_floor_data(data: Dictionary) -> void:
	floor_data = data
	visited_rooms.clear()
	queue_redraw()

func update_room(room_data: Dictionary) -> void:
	if floor_data.is_empty():
		return
	current_room_id = room_data.id
	if room_data.id not in visited_rooms:
		visited_rooms.append(room_data.id)
	queue_redraw()

func _on_room_entered(room_data: Dictionary) -> void:
	update_room(room_data)

func _draw() -> void:
	if floor_data.is_empty() or not floor_data.has("rooms"):
		return

	var rooms: Array = floor_data.rooms

	# Find grid bounds for centering
	var min_pos := Vector2i(999, 999)
	var max_pos := Vector2i(-999, -999)
	for room in rooms:
		var gp: Vector2i = room.grid_pos
		min_pos.x = min(min_pos.x, gp.x)
		min_pos.y = min(min_pos.y, gp.y)
		max_pos.x = max(max_pos.x, gp.x)
		max_pos.y = max(max_pos.y, gp.y)

	var grid_size := max_pos - min_pos + Vector2i.ONE
	var total_size := Vector2(grid_size) * (CELL_SIZE + CELL_GAP)
	var center_offset := (size - total_size) / 2.0

	for room in rooms:
		var gp: Vector2i = room.grid_pos - min_pos
		var rect_pos := Vector2(gp) * (CELL_SIZE + CELL_GAP) + center_offset
		var rect := Rect2(rect_pos, Vector2(CELL_SIZE, CELL_SIZE))

		var color: Color
		if room.id == current_room_id:
			color = Color.YELLOW
		elif room.id in visited_rooms:
			color = Color(0.6, 0.6, 0.6)
		else:
			color = Color(0.25, 0.25, 0.25)

		draw_rect(rect, color)

		# Draw boss indicator
		if room.type == "boss" and room.id in visited_rooms:
			draw_rect(rect.grow(-3), Color.RED)
