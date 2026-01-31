extends Node
class_name RoomManager

var floor_data: Dictionary = {}
var current_room_id: int = 0
var room_container: Node2D
var player: Player
var transition_overlay: ColorRect

var _transitioning: bool = false

func _ready() -> void:
	EventBus.player_entered_door.connect(_on_player_entered_door)

func setup(container: Node2D, p: Player, overlay: ColorRect) -> void:
	room_container = container
	player = p
	transition_overlay = overlay

func start_floor() -> void:
	floor_data = FloorGenerator.generate_floor(7)
	GameData.reset_run()
	current_room_id = 0
	_load_room(0, Vector2i.ZERO)

func _load_room(room_id: int, entry_direction: Vector2i) -> void:
	# Clear existing room contents (keep player)
	for child in room_container.get_children():
		if child == player:
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

	# Place player
	if entry_direction == Vector2i.ZERO:
		player.position = room.get_room_center()
	else:
		player.position = Room.get_entry_position(entry_direction)

	# Spawn enemies if room not cleared and not start room
	if not already_cleared and room_data.type != "start":
		var count := EnemySpawner.spawn_enemies(room, room_container)
		if count == 0:
			room.is_cleared = true
			GameData.mark_room_cleared(room_id)
	else:
		room.is_cleared = true
		room.unlock_doors()

	current_room_id = room_id
	EventBus.room_entered.emit(room_data)

func _on_player_entered_door(direction: Vector2i) -> void:
	if _transitioning:
		return

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

func _transition_to_room(target_room_id: int, entry_direction: Vector2i) -> void:
	_transitioning = true
	player.set_physics_process(false)

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

	player.set_physics_process(true)
	_transitioning = false
