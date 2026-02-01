extends State
class_name PlayerNormal

@export var player: CharacterBody2D
@export var speed: int = 300
@export var animation: AnimatedSprite2D

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_start)

func get_input() -> void:
	if NetworkManager.is_online() and not player.is_multiplayer_authority():
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
	# Only process input, physics, and attacks on the authority player.
	# Non-authority players have their position/velocity synced by MultiplayerSynchronizer.
	if not NetworkManager.is_online() or player.is_multiplayer_authority():
		get_input()
		player.move_and_slide()
		player.try_attack()
		player.aim_direction = (player.get_global_mouse_position() - player.global_position).normalized()

	# Handle animation for all players (uses synced velocity for remote players)
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
