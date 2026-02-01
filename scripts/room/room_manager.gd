extends Node
class_name RoomManager

var floor_data: Dictionary = {}
var current_room_id: int = 0
var room_container: Node2D
var player: Player  # Primary player (backwards compat)
var all_players: Dictionary = {}  # peer_id -> Player
var transition_overlay: ColorRect

var _transitioning: bool = false

func _ready() -> void:
	EventBus.player_entered_door.connect(_on_player_entered_door)

func setup(container: Node2D, p: Player, overlay: ColorRect) -> void:
	room_container = container
	player = p
	transition_overlay = overlay

func start_floor() -> void:
	if not NetworkManager.is_online() or multiplayer.is_server():
		# Host generates the floor
		floor_data = FloorGenerator.generate_floor(7)
		GameData.reset_run()
		current_room_id = 0
		_load_room(0, Vector2i.ZERO)

		# Send floor data to client
		if NetworkManager.is_online():
			var serialized := _serialize_floor_data(floor_data)
			_receive_floor_data.rpc(serialized)

func _load_room(room_id: int, entry_direction: Vector2i) -> void:
	# Clear existing room contents (keep players)
	for child in room_container.get_children():
		if child is Player:
			continue
		child.queue_free()

	# Get room data
	var room_data: Dictionary = floor_data.rooms[room_id]
	var already_cleared: bool = GameData.is_room_cleared(room_id)

	# Build door connections for this room
	var door_dirs: Array[Vector2i] = []
	for dir in room_data.connections:
		door_dirs.append(dir)

	# Create room
	var room := Room.new()
	var spawn_pts: Array[Vector2] = []
	for pt in room_data.spawn_points:
		spawn_pts.append(pt)
	room.setup(room_id, door_dirs, spawn_pts, already_cleared)
	room_container.add_child(room)

	# Place players
	var center := room.get_room_center()
	var entry_pos := Room.get_entry_position(entry_direction) if entry_direction != Vector2i.ZERO else center

	var player_list: Array = all_players.values() if all_players.size() > 0 else [player]
	var offset := 0
	for p: Player in player_list:
		var pos := entry_pos + Vector2(offset * 30, 0)
		p.position = pos
		offset += 1

	# Spawn enemies if room not cleared and not start room
	if not already_cleared and room_data.type != "start":
		if not NetworkManager.is_online() or multiplayer.is_server():
			var count := EnemySpawner.spawn_enemies(room, room_container)
			if count == 0:
				room.is_cleared = true
				room.unlock_doors()
				GameData.mark_room_cleared(room_id)
		else:
			# Client: register expected enemy count so door tracking works
			# when _remote_die RPCs arrive
			for _pt in room.spawn_points:
				room.register_enemy()
	else:
		room.is_cleared = true
		room.unlock_doors()

	current_room_id = room_id
	EventBus.room_entered.emit(room_data)

func _on_player_entered_door(direction: Vector2i) -> void:
	if _transitioning:
		return

	# In multiplayer, only host processes door transitions
	if NetworkManager.is_online() and not multiplayer.is_server():
		_request_door_transition.rpc_id(1, direction)
		return

	_process_door_transition(direction)

func _process_door_transition(direction: Vector2i) -> void:
	var current_room_data: Dictionary = floor_data.rooms[current_room_id]
	var target_pos: Vector2i = current_room_data.grid_pos + direction

	# Find target room
	var target_room_id := -1
	for room_data in floor_data.rooms:
		if room_data.grid_pos == target_pos:
			target_room_id = room_data.id
			break

	if target_room_id == -1:
		return

	_transition_to_room(target_room_id, direction)
	if NetworkManager.is_online():
		_remote_transition.rpc(target_room_id, direction)

@rpc("any_peer", "call_remote", "reliable")
func _request_door_transition(direction: Vector2i) -> void:
	# Client requests host to transition
	if multiplayer.is_server():
		_process_door_transition(direction)

@rpc("authority", "call_remote", "reliable")
func _remote_transition(target_room_id: int, entry_direction: Vector2i) -> void:
	_transition_to_room(target_room_id, entry_direction)

func _transition_to_room(target_room_id: int, entry_direction: Vector2i) -> void:
	_transitioning = true

	# Disable physics for all players
	var player_list: Array = all_players.values() if all_players.size() > 0 else [player]
	for p: Player in player_list:
		p.set_physics_process(false)

	if transition_overlay:
		var tween := create_tween()
		tween.tween_property(transition_overlay, "modulate:a", 1.0, 0.15)
		await tween.finished

	# Wait a frame for queue_free to process
	_load_room(target_room_id, entry_direction)
	await get_tree().process_frame

	if transition_overlay:
		var tween := create_tween()
		tween.tween_property(transition_overlay, "modulate:a", 0.0, 0.15)
		await tween.finished

	for p: Player in player_list:
		p.set_physics_process(true)
	_transitioning = false

# Serialization helpers for sending floor data over network
func _serialize_floor_data(data: Dictionary) -> Dictionary:
	var rooms_arr: Array = []
	for room in data.rooms:
		var r := {}
		r.id = room.id
		r.grid_pos = [room.grid_pos.x, room.grid_pos.y]
		r.type = room.type
		var conns: Array = []
		for c in room.connections:
			conns.append([c.x, c.y])
		r.connections = conns
		var spawns: Array = []
		for s in room.spawn_points:
			spawns.append([s.x, s.y])
		r.spawn_points = spawns
		rooms_arr.append(r)
	return { rooms = rooms_arr }

func _deserialize_floor_data(data: Dictionary) -> Dictionary:
	var rooms: Array[Dictionary] = []
	var grid: Dictionary = {}
	for r in data.rooms:
		var room := {}
		room.id = r.id
		room.grid_pos = Vector2i(r.grid_pos[0], r.grid_pos[1])
		room.type = r.type
		var conns: Array[Vector2i] = []
		for c in r.connections:
			conns.append(Vector2i(c[0], c[1]))
		room.connections = conns
		var spawns: Array[Vector2] = []
		for s in r.spawn_points:
			spawns.append(Vector2(s[0], s[1]))
		room.spawn_points = spawns
		rooms.append(room)
		grid[room.grid_pos] = room
	return { rooms = rooms, grid = grid }

@rpc("authority", "call_remote", "reliable")
func _receive_floor_data(data: Dictionary) -> void:
	floor_data = _deserialize_floor_data(data)
	GameData.reset_run()
	current_room_id = 0
	_load_room(0, Vector2i.ZERO)
