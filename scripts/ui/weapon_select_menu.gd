extends Control

const WEAPON_TYPES := [0, 1, 2]  # BOW, SPEAR, SWORD

var selected_index: int = 0

var border_normal: Texture2D = preload("res://assets/ui/GAMEJAM2026_UI_WeaponSelectionNoGlow.png")
var border_hover: Texture2D = preload("res://assets/ui/GAMEJAM2026_UI_WeaponSelectionGlow.png")

@onready var weapon_panels: Array[TextureRect] = [
	$VBoxContainer/WeaponGrid/BowPanel,
	$VBoxContainer/WeaponGrid/SpearPanel,
	$VBoxContainer/WeaponGrid/SwordPanel,
]

func _ready() -> void:
	selected_index = PlayerData.selected_weapon
	_update_highlight()

func _on_weapon_selected(index: int) -> void:
	selected_index = index
	PlayerData.selected_weapon = WEAPON_TYPES[index]
	_update_highlight()

func _update_highlight() -> void:
	for i in weapon_panels.size():
		if i == selected_index:
			weapon_panels[i].texture = border_hover
		else:
			weapon_panels[i].texture = border_normal

func _on_panel_hover(index: int) -> void:
	weapon_panels[index].texture = border_hover

func _on_panel_unhover(index: int) -> void:
	if index != selected_index:
		weapon_panels[index].texture = border_normal

func _on_start_button_pressed() -> void:
	EventBus.game_started.emit()
	if SceneChanger:
		SceneChanger.change_scene("res://scenes/rooms/types/cutscenes/cutscene2.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/rooms/types/cutscenes/cutscene2.tscn")

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
