extends CanvasLayer

var hearts_container: HBoxContainer
var p2_hearts_container: HBoxContainer
var stats_label: Label
var minimap: Control
var game_over_screen: Control

var _local_peer_id: int = 1

func _ready() -> void:
	layer = 5

	_local_peer_id = multiplayer.get_unique_id() if NetworkManager.is_online() else 1

	_create_hearts()
	_create_p2_hearts()
	_create_stats_label()
	_create_minimap()
	_create_game_over_screen()

	EventBus.player_damaged.connect(_on_player_health_changed)
	EventBus.player_healed.connect(_on_player_health_changed)
	EventBus.player_stats_changed.connect(_on_stats_changed)
	EventBus.player_died.connect(_on_player_died)
	EventBus.room_entered.connect(_on_room_entered)

	# Initial hearts display
	_update_hearts(hearts_container, 6, 6)

func _create_hearts() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_TOP_LEFT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 10)
	add_child(margin)

	hearts_container = HBoxContainer.new()
	hearts_container.add_theme_constant_override("separation", 4)
	margin.add_child(hearts_container)

func _create_p2_hearts() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_TOP_LEFT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 38)
	add_child(margin)

	p2_hearts_container = HBoxContainer.new()
	p2_hearts_container.add_theme_constant_override("separation", 3)
	p2_hearts_container.visible = NetworkManager.is_online()
	margin.add_child(p2_hearts_container)

	if NetworkManager.is_online():
		_update_hearts(p2_hearts_container, 6, 6, true)

func _create_stats_label() -> void:
	stats_label = Label.new()
	stats_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	stats_label.position = Vector2(20, 60 if NetworkManager.is_online() else 50)
	stats_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	stats_label.add_theme_font_size_override("font_size", 14)
	stats_label.text = ""
	add_child(stats_label)

func _create_minimap() -> void:
	minimap = preload("res://scripts/ui/minimap.gd").new()
	minimap.name = "Minimap"
	minimap.anchor_left = 1.0
	minimap.anchor_right = 1.0
	minimap.offset_left = -130
	minimap.offset_top = 10
	minimap.offset_right = -10
	minimap.offset_bottom = 130
	minimap.custom_minimum_size = Vector2(120, 120)
	add_child(minimap)

func _create_game_over_screen() -> void:
	game_over_screen = Control.new()
	game_over_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	game_over_screen.visible = false
	game_over_screen.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(game_over_screen)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.0)
	game_over_screen.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	game_over_screen.add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "YOU DIED"
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", Color(0.85, 0.1, 0.1))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var stats_box := VBoxContainer.new()
	stats_box.alignment = BoxContainer.ALIGNMENT_CENTER
	stats_box.add_theme_constant_override("separation", 6)
	vbox.add_child(stats_box)

	var kills_label := Label.new()
	kills_label.name = "KillsLabel"
	kills_label.add_theme_font_size_override("font_size", 22)
	kills_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	kills_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_box.add_child(kills_label)

	var pickups_label := Label.new()
	pickups_label.name = "PickupsLabel"
	pickups_label.add_theme_font_size_override("font_size", 22)
	pickups_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	pickups_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_box.add_child(pickups_label)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)

	var restart_btn := Button.new()
	restart_btn.text = "Return to Menu"
	restart_btn.custom_minimum_size = Vector2(220, 50)
	restart_btn.pressed.connect(_on_restart_pressed)
	vbox.add_child(restart_btn)

	# Store bg ref for fade-in
	game_over_screen.set_meta("bg", bg)

func _update_hearts(container: HBoxContainer, current_hp: int, max_hp: int, small: bool = false) -> void:
	for child in container.get_children():
		child.queue_free()

	var full_hearts := current_hp / 2
	var half_heart := current_hp % 2
	var empty_hearts := (max_hp - current_hp) / 2

	var size := Vector2(16, 16) if small else Vector2(24, 24)

	for i in range(full_hearts):
		container.add_child(_make_heart(Color(0.9, 0.15, 0.15), size))

	if half_heart:
		container.add_child(_make_heart(Color(0.9, 0.4, 0.4), size))

	for i in range(empty_hearts):
		container.add_child(_make_heart(Color(0.3, 0.3, 0.3), size))

func _make_heart(color: Color, size: Vector2 = Vector2(24, 24)) -> ColorRect:
	var heart := ColorRect.new()
	heart.custom_minimum_size = size
	heart.color = color
	return heart

func _on_player_health_changed(peer_id: int, current_hp: int, max_hp: int) -> void:
	if peer_id == _local_peer_id:
		_update_hearts(hearts_container, current_hp, max_hp)
	else:
		p2_hearts_container.visible = true
		_update_hearts(p2_hearts_container, current_hp, max_hp, true)

func _on_stats_changed(peer_id: int, stats: Dictionary) -> void:
	if peer_id == _local_peer_id:
		stats_label.text = "DMG: %d  SPD: %d" % [stats.damage, int(stats.speed)]

func _on_player_died(_peer_id: int = 0) -> void:
	# Populate stats
	var kills_label := game_over_screen.find_child("KillsLabel") as Label
	var pickups_label := game_over_screen.find_child("PickupsLabel") as Label
	if kills_label:
		kills_label.text = "Kills: %d" % PlayerData.kills
	if pickups_label:
		pickups_label.text = "Pickups: %d" % PlayerData.pickups

	# Fade in
	game_over_screen.visible = true
	game_over_screen.modulate = Color(1, 1, 1, 0)
	var bg: ColorRect = game_over_screen.get_meta("bg")
	bg.color = Color(0, 0, 0, 0)
	var tween := create_tween()
	tween.tween_property(game_over_screen, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(bg, "color:a", 0.75, 0.8)

func _on_restart_pressed() -> void:
	game_over_screen.visible = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_room_entered(room_data: Dictionary) -> void:
	if minimap and minimap.has_method("update_room"):
		minimap.update_room(room_data)
