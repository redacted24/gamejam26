extends Room

@export_file_path var resource_path : String

# Hard-coded cutscene

func _ready() -> void:
	print("entered cutscene 2 state")
	var resource : DialogueResource = load(resource_path)
	show_example_dialogue_baloon(resource, "start", [])

func show_example_dialogue_baloon(resource: DialogueResource, title: String = "", extra_game_states: Array = []):
	var balloon : Node = load("res://scenes/dialogue/balloon.tscn").instantiate()
	DialogueManager.show_dialogue_balloon_scene(balloon, resource, title)
