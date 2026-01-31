extends State
class_name PlayerNormal

@export var player : CharacterBody2D
@export var speed : int = 300
@export var animation : AnimatedSprite2D

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_start)

func get_input() -> void:
	if not player.is_multiplayer_authority():
		return
	var input_direction : Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player.velocity = input_direction * speed

# Function that handles what happens when dialogue starts
func _on_dialogue_start() -> void:
	pass

func enter() -> void:
	pass

func process(_delta : float) -> void:
	pass

func physics_process(_delta: float) -> void:
	# Get input from the user
	get_input()

	# Handle animation
	# Up
	if player.velocity.y < 0 and player.velocity.x == 0:
		animation.flip_h = 0
		animation.play("walk_up")
	# Left
	elif player.velocity.y == 0 and player.velocity.x < 0:
		animation.flip_h = 1
		animation.play("walk_right")
	# Right
	elif player.velocity.y == 0 and player.velocity.x > 0:
		animation.flip_h = 0
		animation.play("walk_right")
	# Down
	elif player.velocity.y > 0 and player.velocity.x == 0:
		animation.flip_h = 0
		animation.play("walk_down")
	# Up right
	elif player.velocity.y < 0 and player.velocity.x > 0:
		animation.flip_h = 0
		animation.play("walk_up_right")
	# Up left
	elif player.velocity.y < 0 and player.velocity.x < 0:
		animation.flip_h = 1
		animation.play("walk_up_right")
	# Down right
	elif player.velocity.y > 0 and player.velocity.x > 0:
		animation.flip_h = 0
		animation.play("walk_down_right")
	# Down left
	elif player.velocity.y > 0 and player.velocity.x < 0:
		animation.flip_h = 1
		animation.play("walk_down_right")
	# Idle
	elif player.velocity.y == 0 and player.velocity.x == 0:
		animation.stop()
	player.move_and_slide()
	# Animation handling end

	if player.is_multiplayer_authority():
		player.try_attack()
		# Sync aim direction for remote players to see
		player.aim_direction = (player.get_global_mouse_position() - player.global_position).normalized()
