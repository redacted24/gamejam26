extends State
class_name PlayerImmobile

@export var animation : AnimatedSprite2D

func enter() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)
	animation.stop()
	print("entered immobile state")
	pass
	
func exit() -> void:
	pass
	
func process(_delta: float) -> void:
	pass
	
func physics_process(_delta: float) -> void:
	pass

func _on_dialogue_end(resource : DialogueResource) -> void:
	Transitioned.emit(self, "Normal")
