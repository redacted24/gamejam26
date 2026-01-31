extends CanvasLayer

var hearts_container: HBoxContainer
var stats_label: Label
var minimap: Control
var game_over_screen: Control

func _ready() -> void:
	layer = 5

	_create_hearts()
	_create_stats_label()
	_create_minimap()
	_create_game_over_screen()

	EventBus.player_damaged.connect(_on_player_health_changed)
	EventBus.player_healed.connect(_on_player_health_changed)
	EventBus.player_stats_changed.connect(_on_stats_changed)
	EventBus.player_died.connect(_on_player_died)
	EventBus.room_entered.connect(_on_room_entered)

	# Initial hearts display
	_update_hearts(6, 6)

func _create_hearts() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_TOP_LEFT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 10)
	add_child(margin)

	hearts_container = HBoxContainer.new()
	hearts_container.add_theme_constant_override("separation", 4)
	margin.add_child(hearts_container)

func _create_stats_label() -> void:
	stats_label = Label.new()
	stats_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	stats_label.position = Vector2(20, 50)
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
	add_child(game_over_screen)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.7)
	game_over_screen.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	game_over_screen.add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "GAME OVER"
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color.RED)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var restart_btn := Button.new()
	restart_btn.text = "Restart"
	restart_btn.custom_minimum_size = Vector2(200, 50)
	restart_btn.pressed.connect(func(): EventBus.restart_requested.emit())
	vbox.add_child(restart_btn)

func _update_hearts(current_hp: int, max_hp: int) -> void:
	for child in hearts_container.get_children():
		child.queue_free()

	var full_hearts := current_hp / 2
	var half_heart := current_hp % 2
	var empty_hearts := (max_hp - current_hp) / 2

	for i in range(full_hearts):
		hearts_container.add_child(_make_heart(Color(0.9, 0.15, 0.15)))

	if half_heart:
		hearts_container.add_child(_make_heart(Color(0.9, 0.4, 0.4)))

	for i in range(empty_hearts):
		hearts_container.add_child(_make_heart(Color(0.3, 0.3, 0.3)))

func _make_heart(color: Color) -> ColorRect:
	var heart := ColorRect.new()
	heart.custom_minimum_size = Vector2(24, 24)
	heart.color = color
	return heart

func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	_update_hearts(current_hp, max_hp)

func _on_stats_changed(stats: Dictionary) -> void:
	stats_label.text = "DMG: %d  SPD: %d" % [stats.damage, int(stats.speed)]

func _on_player_died() -> void:
	game_over_screen.visible = true

func _on_room_entered(room_data: Dictionary) -> void:
	if minimap and minimap.has_method("update_room"):
		minimap.update_room(room_data)
