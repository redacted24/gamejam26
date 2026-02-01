extends Node2D
class_name WeaponBase

@export var damage: int = 1
@export var attack_rate: float = 0.4
@export var horizontal_offset: float = 15.0

var player: CharacterBody2D
var can_attack: bool = true
var attack_timer: Timer
var sprite: Sprite2D

func _ready() -> void:
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_rate
	attack_timer.one_shot = true
	attack_timer.timeout.connect(func(): can_attack = true)
	add_child(attack_timer)
	sprite = get_node_or_null("Sprite")

func setup(p: CharacterBody2D) -> void:
	player = p

func try_attack() -> void:
	if not can_attack:
		return
	if NetworkManager.is_online() and not player.is_multiplayer_authority():
		return
	if not Input.is_action_pressed("shoot"):
		return
	var attack_dir := _get_attack_direction()
	_perform_attack(attack_dir)

func _get_attack_direction() -> Vector2:
	if not NetworkManager.is_online() or player.is_multiplayer_authority():
		return (player.get_global_mouse_position() - player.global_position).normalized()
	else:
		return player.aim_direction

func _perform_attack(_dir: Vector2) -> void:
	can_attack = false
	attack_timer.start()

func _update_aim() -> void:
	if not sprite or not player:
		return
	var direction: Vector2
	var is_left: bool
	if not NetworkManager.is_online() or player.is_multiplayer_authority():
		var mouse_pos := player.get_global_mouse_position()
		direction = (mouse_pos - player.global_position).normalized()
		is_left = mouse_pos.x < player.global_position.x
	else:
		direction = player.aim_direction
		is_left = player.aim_direction.x < 0

	rotation = direction.angle()
	sprite.flip_v = is_left
	position.x = -horizontal_offset if is_left else horizontal_offset
