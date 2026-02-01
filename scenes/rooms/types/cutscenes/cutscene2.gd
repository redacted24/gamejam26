extends Room

@export_file_path var resource_path : String
@onready var door_collision : CollisionShape2D = $Doors/HorizontalDoor/CollisionShape2D

# Hard-coded cutscene

func _ready() -> void:
	# Hide doors because it is currently directly on the player. Only unhide collision at the end of cutscene
	door_collision.set_deferred("disabled", true)
	# Signals handling (emitting and connecting)
	EventBus.cutscene_enter.emit()
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)
	print("entered cutscene 2 state")
	# Play fade in animation
	SceneChanger.animation_player.play("long_fade_in")
	# Hide the player
	player.hide()
	var timer : Timer = $Timer
	timer.start()
	await timer.timeout
	var resource : DialogueResource = load(resource_path)
	show_example_dialogue_baloon(resource, "start", [])
	# Assign doors
	assign_doors()
	
func _on_dialogue_end(resource : DialogueResource) -> void:
	print("reenabling door collision")
	door_collision.set_deferred("disabled", false)
	

func show_example_dialogue_baloon(resource: DialogueResource, title: String = "", extra_game_states: Array = []):
	var balloon : Node = load("res://scenes/dialogue/balloon.tscn").instantiate()
	DialogueManager.show_dialogue_balloon_scene(balloon, resource, title)
