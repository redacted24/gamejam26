extends State
class_name PlayerNormal

@export var player : CharacterBody2D
@export var speed : int = 300
var animation : AnimatedSprite2D

func _ready() -> void:
	animation = player.get_node("AnimatedSprite2D")
	DialogueManager.dialogue_started.connect(_on_dialogue_start)
	
func _on_dialogue_start() -> void:
	pass
	
func physics_process(_delta: float) -> void:
	var player: Player = get_parent().get_parent()
	player.try_shoot()

	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir == Vector2.ZERO:
		Transitioned.emit(self, "idle")
		return

	player.velocity = dir * player.stats.speed
	player.move_and_slide()
