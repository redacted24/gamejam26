extends Control

const WEAPONS := [
	{
		"name": "Bow",
		"description": "Ranged weapon.\nSafe damage from a distance.",
		"icon": "res://assets/weapons/bow000.png",
		"type": 0,  # Player.WeaponType.BOW
	},
	{
		"name": "Spear",
		"description": "Long melee weapon.\nGood reach and speed.",
		"icon": "res://assets/weapons/spear.png",
		"type": 1,  # Player.WeaponType.SPEAR
	},
	{
		"name": "Sword",
		"description": "Close melee weapon.\nHigh damage, short range.",
		"icon": "res://assets/weapons/sword_idle.png",
		"type": 2,  # Player.WeaponType.SWORD
	},
]

var weapon_panels: Array[PanelContainer] = []
var selected_index: int = 0

@onready var weapon_grid: HBoxContainer = $VBoxContainer/WeaponGrid

func _ready() -> void:
	selected_index = PlayerData.selected_weapon
	_build_weapon_buttons()
	_update_highlight()

func _build_weapon_buttons() -> void:
	for i in WEAPONS.size():
		var weapon: Dictionary = WEAPONS[i]

		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(140, 260)

		var vbox := VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 10)

		var name_label := Label.new()
		name_label.text = weapon["name"]
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 28)

		var icon := TextureRect.new()
		icon.texture = load(weapon["icon"])
		icon.custom_minimum_size = Vector2(80, 80)
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

		var desc_label := Label.new()
		desc_label.text = weapon["description"]
		desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc_label.add_theme_font_size_override("font_size", 16)
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		var select_btn := Button.new()
		select_btn.text = "Select"
		select_btn.pressed.connect(_on_weapon_selected.bind(i))

		vbox.add_child(name_label)
		vbox.add_child(icon)
		vbox.add_child(desc_label)
		vbox.add_child(select_btn)
		panel.add_child(vbox)
		weapon_grid.add_child(panel)
		weapon_panels.append(panel)

func _on_weapon_selected(index: int) -> void:
	selected_index = index
	PlayerData.selected_weapon = WEAPONS[index]["type"]
	_update_highlight()

func _update_highlight() -> void:
	for i in weapon_panels.size():
		var style := StyleBoxFlat.new()
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_left = 8
		style.corner_radius_bottom_right = 8
		if i == selected_index:
			style.bg_color = Color(0.2, 0.35, 0.55, 1.0)
			style.border_width_bottom = 3
			style.border_width_top = 3
			style.border_width_left = 3
			style.border_width_right = 3
			style.border_color = Color(0.4, 0.7, 1.0)
		else:
			style.bg_color = Color(0.15, 0.15, 0.15, 1.0)
			style.border_width_bottom = 2
			style.border_width_top = 2
			style.border_width_left = 2
			style.border_width_right = 2
			style.border_color = Color(0.3, 0.3, 0.3)
		weapon_panels[i].add_theme_stylebox_override("panel", style)

func _on_start_button_pressed() -> void:
	EventBus.game_started.emit()
	get_tree().change_scene_to_file("res://scenes/rooms/types/room_crossroads.tscn")

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
