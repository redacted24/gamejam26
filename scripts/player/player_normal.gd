extends State
class_name PlayerNormal

@export var player: CharacterBody2D
@export var speed: int = 300
@export var animation: AnimatedSprite2D

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_start)

func get_input() -> void:
	if not player.is_multiplayer_authority():
		return
	var input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player.velocity = input_direction * speed

func _on_dialogue_start() -> void:
	pass

func enter() -> void:
	pass

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	get_input()

	# Handle animation
	if player.velocity.y < 0 and player.velocity.x == 0:
		animation.flip_h = 0
		animation.play("walk_up")
	elif player.velocity.y == 0 and player.velocity.x < 0:
		animation.flip_h = 1
		animation.play("walk_right")
	elif player.velocity.y == 0 and player.velocity.x > 0:
		animation.flip_h = 0
		animation.play("walk_right")
	elif player.velocity.y > 0 and player.velocity.x == 0:
		animation.flip_h = 0
		animation.play("walk_down")
	elif player.velocity.y < 0 and player.velocity.x > 0:
		animation.flip_h = 0
		animation.play("walk_up_right")
	elif player.velocity.y < 0 and player.velocity.x < 0:
		animation.flip_h = 1
		animation.play("walk_up_right")
	elif player.velocity.y > 0 and player.velocity.x > 0:
		animation.flip_h = 0
		animation.play("walk_down_right")
	elif player.velocity.y > 0 and player.velocity.x < 0:
		animation.flip_h = 1
		animation.play("walk_down_right")
	elif player.velocity.y == 0 and player.velocity.x == 0:
		animation.stop()
	player.move_and_slide()

	if player.is_multiplayer_authority():
		player.try_attack()
		player.aim_direction = (player.get_global_mouse_position() - player.global_position).normalized()
