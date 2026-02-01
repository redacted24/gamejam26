extends Node2D

@onready var interact_text : Label
@export_file_path var dialogue_path : String

var valid_interact
var in_dialogue

# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished)
	DialogueManager.dialogue_started.connect(_on_dialogue_start)
	interact_text = self.get_node("InteractText")
	interact_text.hide()
	valid_interact = false
	in_dialogue = false

# show example baloon
func show_example_dialogue_baloon(resource: DialogueResource, title: String = "", extra_game_states: Array = []):
	var balloon : Node = load("res://scenes/balloon.tscn").instantiate()
	DialogueManager.show_dialogue_balloon_scene(balloon, resource, title)
	
func _on_dialogue_finished(resource : DialogueResource) -> void:
	in_dialogue = false
	
func _on_dialogue_start(resource : DialogueResource) -> void:
	interact_text.hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") == true && in_dialogue == false && valid_interact == true:
		print("showing balloon")
		in_dialogue = true
		# maybe load an error dialogue if nothing is found
		var resource : DialogueResource = load(dialogue_path)
		show_example_dialogue_baloon(resource, "start", [])
	pass

# On player character body entered
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		valid_interact = true
		interact_text.show()
	pass # Replace with function body.

# On player character body exit
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		valid_interact = false
		interact_text.hide()
		
	pass # Replace with function body.
