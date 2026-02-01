extends Control

@onready var volume_slider: HSlider = $VolumeSlider
@onready var volume_value_label: Label = $VolumeValueLabel

func _ready() -> void:
	var current_db := AudioServer.get_bus_volume_db(0)
	var current_linear := db_to_linear(current_db) * 100.0
	volume_slider.value = current_linear
	_update_volume_label(current_linear)

func _on_volume_slider_value_changed(value: float) -> void:
	var db := linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(0, db)
	_update_volume_label(value)

func _update_volume_label(value: float) -> void:
	volume_value_label.text = "%d%%" % int(value)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
