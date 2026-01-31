extends RefCounted
class_name FloorGenerator

const DIRECTIONS := [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]

# Room spawn point presets (different layouts)
const SPAWN_LAYOUTS: Array[Array] = [
	[Vector2(200, 150), Vector2(760, 150), Vector2(480, 400)],
	[Vector2(200, 150), Vector2(760, 400), Vector2(200, 400), Vector2(760, 150)],
	[Vector2(480, 150), Vector2(250, 350), Vector2(710, 350)],
	[Vector2(300, 270), Vector2(660, 270), Vector2(480, 150), Vector2(480, 400)],
	[Vector2(200, 200), Vector2(760, 200), Vector2(200, 380), Vector2(760, 380), Vector2(480, 270)],
]

static func generate_floor(room_count: int = 7) -> Dictionary:
	var grid: Dictionary = {}
	var rooms: Array[Dictionary] = []
	var open_slots: Array[Vector2i] = []

	# Place start room
	var start_room := {
		id = 0,
		grid_pos = Vector2i(0, 0),
		type = "start",
		connections = [] as Array[Vector2i],
		spawn_points = [] as Array[Vector2],
	}
	grid[Vector2i(0, 0)] = start_room
	rooms.append(start_room)

	for dir in DIRECTIONS:
		open_slots.append(dir)

	# Expand rooms
	while rooms.size() < room_count and open_slots.size() > 0:
		open_slots.shuffle()
		var pos: Vector2i = open_slots.pop_back()

		if grid.has(pos):
			continue

		var neighbors := _get_occupied_neighbors(grid, pos)
		if neighbors.size() > 2:
			continue

		var room_data := {
			id = rooms.size(),
			grid_pos = pos,
			type = "normal",
			connections = [] as Array[Vector2i],
			spawn_points = SPAWN_LAYOUTS.pick_random().duplicate(),
		}
		grid[pos] = room_data
		rooms.append(room_data)

		for neighbor_pos in neighbors:
			var dir: Vector2i = pos - neighbor_pos
			room_data.connections.append(dir)
			grid[neighbor_pos].connections.append(-dir)

		for dir in DIRECTIONS:
			var adj: Vector2i = pos + dir
			if not grid.has(adj) and adj not in open_slots:
				open_slots.append(adj)

	# Assign boss room (furthest from start)
	var furthest_id := _find_furthest_room(rooms)
	rooms[furthest_id].type = "boss"
	rooms[furthest_id].spawn_points = [
		Vector2(300, 200), Vector2(660, 200),
		Vector2(300, 380), Vector2(660, 380),
		Vector2(480, 270),
	]

	return { rooms = rooms, grid = grid }

static func _get_occupied_neighbors(grid: Dictionary, pos: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for dir in DIRECTIONS:
		var adj: Vector2i = pos + dir
		if grid.has(adj):
			result.append(adj)
	return result

static func _find_furthest_room(rooms: Array[Dictionary]) -> int:
	# BFS from room 0 to find the furthest room
	var visited: Dictionary = {}
	var queue: Array[int] = [0]
	visited[0] = true
	var last_id := 0

	while queue.size() > 0:
		var current_id: int = queue.pop_front()
		last_id = current_id
		var room: Dictionary = rooms[current_id]

		for connection_dir in room.connections:
			var neighbor_pos: Vector2i = room.grid_pos + connection_dir
			for r in rooms:
				if r.grid_pos == neighbor_pos and not visited.has(r.id):
					visited[r.id] = true
					queue.append(r.id)

	return last_id
