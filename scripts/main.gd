extends Node2D

var room_container: Node2D
var players: Dictionary = {}  # peer_id -> Player
var room_manager: RoomManager
var transition_overlay: ColorRect
var hud: CanvasLayer

func _ready() -> void:
	room_container = $RoomContainer

	_create_transition_overlay()
	_create_players()
	_create_hud()
	_create_room_manager()

	EventBus.player_died.connect(_on_player_died)
	EventBus.restart_requested.connect(_on_restart)
	EventBus.pickup_collected.connect(_on_pickup_collected)
	EventBus.enemy_died.connect(_on_enemy_died)

	room_manager.start_floor()

	# Pass floor data to minimap and trigger initial room display
	var minimap := hud.get_node_or_null("Minimap")
	if minimap:
		minimap.set_floor_data(room_manager.floor_data)
		minimap.update_room(room_manager.floor_data.rooms[0])

func _create_players() -> void:
	var player_scene := preload("res://scenes/player.tscn")
	var peer_ids: Array

	if NetworkManager.is_online():
		peer_ids = NetworkManager.get_peer_ids()
	else:
		peer_ids = [1]  # Solo play

	var offset_idx := 0
	for pid in peer_ids:
		var p: Player = player_scene.instantiate()
		p.name = "Player_%d" % pid
		p.peer_id = pid
		p.set_multiplayer_authority(pid)
		room_container.add_child(p)
		players[pid] = p

		# Only the local player gets an active camera
		var cam := p.get_node_or_null("Camera2D") as Camera2D
		if cam:
			var my_id := multiplayer.get_unique_id() if NetworkManager.is_online() else 1
			cam.enabled = (pid == my_id)

		offset_idx += 1

func _get_local_player() -> Player:
	var my_id := multiplayer.get_unique_id() if NetworkManager.is_online() else 1
	return players.get(my_id)

func _create_room_manager() -> void:
	room_manager = RoomManager.new()
	room_manager.name = "RoomManager"
	# Pass the first player for backwards compat; room_manager also gets all players
	var first_player: Player = players.values()[0]
	room_manager.setup(room_container, first_player, transition_overlay)
	room_manager.all_players = players
	add_child(room_manager)

func _create_transition_overlay() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)

	transition_overlay = ColorRect.new()
	transition_overlay.color = Color.BLACK
	transition_overlay.modulate.a = 0.0
	transition_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(transition_overlay)

func _create_hud() -> void:
	var hud_script := preload("res://scripts/ui/hud.gd")
	hud = CanvasLayer.new()
	hud.set_script(hud_script)
	hud.name = "HUD"
	add_child(hud)

func _on_player_died(peer_id: int) -> void:
	# Check if all players are dead
	var all_dead := true
	for p: Player in players.values():
		if p.health_component.current_hp > 0:
			all_dead = false
			break
	if all_dead:
		pass  # Game over handled by HUD

func _on_restart() -> void:
	get_tree().reload_current_scene()

func _on_pickup_collected(pickup_type: String, value: float) -> void:
	# Apply pickup to the nearest player
	# In multiplayer, pickups go to whoever touched them (handled by pickup area)
	# Fallback: apply to local player
	var local := _get_local_player()
	if local:
		local.apply_pickup(pickup_type, value)

func _on_enemy_died(pos: Vector2) -> void:
	PickupDropper.try_drop(pos, room_container)
