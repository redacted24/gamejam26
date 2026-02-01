extends CanvasLayer

# Main control node
@export var control_node : Control

# Individual items
@export var hunger_label : Label
@export var hitpoints_label : Label
@export var hp_bar : ColorRect
@export var hunger_bar : ColorRect

const BAR_MAX_WIDTH := 234.0

var game_over_screen: Control
var _game_over_bg: ColorRect

func _ready() -> void:
	# initially hide the game ui elements
	control_node.hide()
	update_hunger_label()
	update_hunger_bar()
	update_hitpoints_label()
	update_hitpoints_bar()
	_create_game_over_screen()

	# Signals
	EventBus.refresh_ui.connect(_on_ui_refresh)
	EventBus.show_ui.connect(_on_ui_show_signal)
	EventBus.hide_ui.connect(_on_ui_hide_signal)
	EventBus.cutscene_enter.connect(_on_cutscene_enter)
	EventBus.player_died.connect(_on_player_died)
	
func _on_cutscene_enter() -> void:
	control_node.hide()

func _on_ui_show_signal() -> void:
	control_node.show()
	
func _on_ui_hide_signal() -> void:
	control_node.hide()

	
# Fetches the player data for hunger and max hunger from PlayerData and updates label
func update_hunger_label() -> void:
	hunger_label.text = "%d / %d" % [PlayerData.hunger, PlayerData.max_hunger]

# Updates the hunger bar size based on current/max ratio
func update_hunger_bar() -> void:
	if not hunger_bar or PlayerData.max_hunger <= 0:
		return
	var ratio := clampf(float(PlayerData.hunger) / float(PlayerData.max_hunger), 0.0, 1.0)
	hunger_bar.size.x = BAR_MAX_WIDTH * ratio

# Fetches the player data for hitpoints and max hitpoints from PlayerData and updates data
func update_hitpoints_label() -> void:
	hitpoints_label.text = "%d / %d" % [PlayerData.hitpoints, PlayerData.max_hitpoints]

# Updates the HP bar size based on current/max ratio
func update_hitpoints_bar() -> void:
	if not hp_bar or PlayerData.max_hitpoints <= 0:
		return
	var ratio := clampf(float(PlayerData.hitpoints) / float(PlayerData.max_hitpoints), 0.0, 1.0)
	hp_bar.size.x = BAR_MAX_WIDTH * ratio

# Called when a signal to refresh ui is made
func _on_ui_refresh() -> void:
	update_hunger_label()
	update_hunger_bar()
	update_hitpoints_label()
	update_hitpoints_bar()
	
func process() -> void:
	pass
	
func _create_game_over_screen() -> void:
	game_over_screen = Control.new()
	game_over_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	game_over_screen.visible = false
	game_over_screen.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(game_over_screen)

	_game_over_bg = ColorRect.new()
	_game_over_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_game_over_bg.color = Color(0, 0, 0, 0)
	game_over_screen.add_child(_game_over_bg)

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

	var reason_label := Label.new()
	reason_label.name = "ReasonLabel"
	reason_label.add_theme_font_size_override("font_size", 24)
	reason_label.add_theme_color_override("font_color", Color(1.0, 0.75, 0.75))
	reason_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(reason_label)

	var kills_label := Label.new()
	kills_label.name = "KillsLabel"
	kills_label.add_theme_font_size_override("font_size", 22)
	kills_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	kills_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(kills_label)

	var pickups_label := Label.new()
	pickups_label.name = "PickupsLabel"
	pickups_label.add_theme_font_size_override("font_size", 22)
	pickups_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	pickups_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(pickups_label)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)

	var restart_btn := Button.new()
	restart_btn.text = "Return to Menu"
	restart_btn.custom_minimum_size = Vector2(220, 50)
	restart_btn.pressed.connect(_on_restart_pressed)
	vbox.add_child(restart_btn)

func _on_player_died(_peer_id: int = 0) -> void:
	var reason_label := game_over_screen.find_child("ReasonLabel") as Label
	if reason_label:
		reason_label.text = PlayerData.death_reason if PlayerData.death_reason != "" else "Unknown cause"
	var kills_label := game_over_screen.find_child("KillsLabel") as Label
	var pickups_label := game_over_screen.find_child("PickupsLabel") as Label
	if kills_label:
		kills_label.text = "Kills: %d" % PlayerData.kills
	if pickups_label:
		pickups_label.text = "Pickups: %d" % PlayerData.pickups

	game_over_screen.visible = true
	game_over_screen.modulate = Color(1, 1, 1, 0)
	_game_over_bg.color = Color(0, 0, 0, 0)
	var tween := create_tween()
	tween.tween_property(game_over_screen, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(_game_over_bg, "color:a", 0.75, 0.8)

func _on_restart_pressed() -> void:
	game_over_screen.visible = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _exit_tree() -> void:
	pass
