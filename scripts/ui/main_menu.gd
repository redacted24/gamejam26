extends Control

@onready var settings_panel: Panel = $SettingsPanel

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/test_scene.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_settings_button_pressed() -> void:
	settings_panel.visible = true

func _on_close_button_pressed() -> void:
	settings_panel.visible = false

func _on_volume_slider_value_changed(value: float) -> void:
	var db := linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(0, db)
