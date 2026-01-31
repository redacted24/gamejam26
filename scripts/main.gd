extends Node2D

var room_container: Node2D
var player: Player
var room_manager: RoomManager
var transition_overlay: ColorRect
var hud: CanvasLayer

func _ready() -> void:
	room_container = $RoomContainer

	_create_transition_overlay()
	_create_player()
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

func _create_player() -> void:
	var player_scene := preload("res://scenes/player.tscn")
	player = player_scene.instantiate()
	room_container.add_child(player)

func _create_room_manager() -> void:
	room_manager = RoomManager.new()
	room_manager.name = "RoomManager"
	room_manager.setup(room_container, player, transition_overlay)
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

func _on_player_died() -> void:
	pass

func _on_restart() -> void:
	get_tree().reload_current_scene()

func _on_pickup_collected(pickup_type: String, value: float) -> void:
	if player:
		player.apply_pickup(pickup_type, value)

func _on_enemy_died(pos: Vector2) -> void:
	PickupDropper.try_drop(pos, room_container)
