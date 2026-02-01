extends Node

signal player_spawn
var spawn_location

func go_to_level(level_path : String, spawn_point : String):
	if not FileAccess.file_exists(level_path):
		return
		
	var scene_to_load := load(level_path)
	if scene_to_load != null:
		spawn_location = spawn_point
		if SceneChanger:
			SceneChanger.change_scene("")
			await EventBus.scene_exit
		get_tree().call_deferred("change_scene_to_packed", scene_to_load)

func trigger_player_spawn(spawn_position) -> void:
	player_spawn.emit(spawn_position)
