extends Room

@export var dialogue_resource: DialogueResource
var dialogue_triggered := false

func _ready() -> void:
	super._ready()
	# Play intro dialogue on load
	play_intro_dialogue()
	# Connect the spawnpoint2 area signal
	var spawnpoint2 = get_node_or_null("SpawnPoints/Spawnpoint2/Area2D")
	if spawnpoint2:
		spawnpoint2.body_entered.connect(_on_spawnpoint2_body_entered)

func play_intro_dialogue() -> void:
	var resource: DialogueResource = load("res://dialogues/1_post_monster_monologue.dialogue")
	var balloon: Node = load("res://scenes/dialogue/balloon.tscn").instantiate()
	get_tree().current_scene.add_child(balloon)
	DialogueManager.show_dialogue_balloon_scene(balloon, resource, "start")

func _on_spawnpoint2_body_entered(body: Node2D) -> void:
	if dialogue_triggered:
		return
	if body is Player:
		dialogue_triggered = true
		show_dialogue_balloon()

func show_dialogue_balloon() -> void:
	var balloon: Node = load("res://scenes/dialogue/balloon.tscn").instantiate()
	get_tree().current_scene.add_child(balloon)
	DialogueManager.show_dialogue_balloon_scene(balloon, dialogue_resource, "start")
