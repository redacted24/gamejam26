extends CanvasLayer

signal scene_changed

@onready var animation_player = $AnimationPlayer
@onready var color_rect = $Control/ColorRect

func change_scene(path : String, delay = 0.5) -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	scene_changed.emit()
