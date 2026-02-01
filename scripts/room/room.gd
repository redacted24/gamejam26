extends Node2D
class_name Room

@export var room_type : MapGeneration.room_types
@export var hunger_cost : int
@export var player : CharacterBody2D

var enemy_count : int
var door_count : int
var is_cleared : bool
var all_doors : Array # array holds all doors (exits)

func _ready() -> void:
	# Fade in. Make player not move
	EventBus.show_ui.emit()
	if SceneChanger and SceneChanger.animation_player:
		SceneChanger.animation_player.play("fade_in")
	# Reduce player hunger by the amount specified
	EventBus.player_hunger_reduced.emit(hunger_cost)
	is_cleared = false

	_setup_multiplayer_players()

	# Connect spawn location signal
	if NavManager and NavManager.spawn_location != null:
		_on_level_spawn(NavManager.spawn_location)

	# Only the host assigns doors in multiplayer (client gets door paths via RPC)
	if not NetworkManager.is_online() or multiplayer.is_server():
		assign_doors()

func _setup_multiplayer_players() -> void:
	if not NetworkManager.is_online():
		return

	# Remove ALL pre-placed Player instances
	var spawn_pos := Vector2.ZERO
	for child in get_children():
		if child is Player:
			spawn_pos = child.position
			remove_child(child)
			child.queue_free()

	# Build peer list from the actual multiplayer API (avoids stale entries)
	var my_id := multiplayer.get_unique_id()
	var peer_ids: Array = [my_id]
	for pid in multiplayer.get_peers():
		peer_ids.append(pid)

	# Create one Player per peer with proper authority and camera
	var player_scene := preload("res://scenes/player.tscn")
	var offset_idx := 0

	for pid in peer_ids:
		var p: Player = player_scene.instantiate()
		p.name = "Player_%d" % pid
		p.peer_id = pid
		p.position = spawn_pos + Vector2(offset_idx * 30, 0)
		add_child(p)
		p.set_multiplayer_authority(pid)

		var cam := p.get_node_or_null("Camera2D") as Camera2D
		if cam:
			cam.enabled = (pid == my_id)

		offset_idx += 1

# Function that assigns door
func assign_doors() -> void:
	# Get all door nodes
	all_doors = get_node("Doors").get_children()
	door_count = all_doors.size()
	# iterate through doors and assign their teleport
	for door : Door in all_doors:
		var next_room = MapGeneration.generate_next_rooms()
		door.next_level.path = next_room.path
		door.next_level.type = next_room.type
		# all rooms should only have one spawnpoint for now
		door.next_level.spawnpoint = "Main"
		#print("a door connects to %s" % next_room[0])
		
func spawn_enemies() -> void:
	pass
	
# Function that determines where the player should spawn
# Emits the signal for the player to spawn
func _on_level_spawn(spawn_location : String) -> void:
	var spawn_path = "SpawnPoints/" + spawn_location
	var spawn : Node2D = get_node(spawn_path)
	# Defer so dynamically created multiplayer players have connected their signals
	NavManager.call_deferred("trigger_player_spawn", spawn.global_position)
