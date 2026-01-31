extends State
class_name PlayerNormal

@export var health_component: HealthComponent
@export var player: CharacterBody2D
@export var speed : int
@export var animation : AnimatedSprite2D

var hunger := 0

enum WeaponType { BOW, SPEAR }

const WEAPON_SCENES := {
	WeaponType.BOW: preload("res://scenes/weapons/bow_weapon.tscn"),
	WeaponType.SPEAR: preload("res://scenes/weapons/spear_weapon.tscn"),
}

var stats := {
	speed = 200.0,
	damage = 1,
	hunger = 0, # taken from playerdata
}

var current_weapon: WeaponBase
var weapon_type: WeaponType = WeaponType.BOW
var invincible: bool = false

func _ready() -> void:
	# Get player data from autoload
	stats.hunger = PlayerData.hunger
	DialogueManager.dialogue_started.connect(_on_dialogue_start)
	# Signal that manages player spawn
	if NavManager:
		NavManager.player_spawn.connect(_on_spawn)
	# Signal that manages player hunger reducing
	EventBus.player_hunger_reduced.connect(_hunger_reduce)
	_equip_weapon(weapon_type)
	
# What happens when player exits tree
func _exit_tree() -> void:
	PlayerData.hunger = stats.hunger
	pass
	
# Function that reduces the amount of hunger from player
func _hunger_reduce(amount : int) -> void:
	stats.hunger -= amount
	print("hunger reduced by %d to : %d" % [amount, stats.hunger])
	if stats.hunger <= 0:
		print("player died of hunger")
		EventBus.player_died.emit()
	pass
	
# Function that handles what happens when dialogue starts
func _on_dialogue_start() -> void:
	pass
	
func get_input() -> void:
	var input_direction : Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player.velocity = input_direction * speed
	
func _on_spawn(spawn_location: Vector2) -> void:
	#print("spawning player at %f and %f" % [spawn_location.x, spawn_location.y])
	player.position = spawn_location

func _equip_weapon(type: WeaponType) -> void:
	if current_weapon:
		current_weapon.queue_free()

	var weapon_scene: PackedScene = WEAPON_SCENES[type]
	current_weapon = weapon_scene.instantiate()
	current_weapon.damage = stats.damage
	current_weapon.setup(player)
	add_child(current_weapon)
	weapon_type = type

func switch_weapon(type: WeaponType) -> void:
	_equip_weapon(type)

func try_attack() -> void:
	if current_weapon:
		current_weapon.try_attack()

func take_damage(amount: int, _hit_position: Vector2 = Vector2.ZERO) -> void:
	if invincible:
		return
	health_component.take_damage(amount)
	EventBus.player_damaged.emit(health_component.current_hp, health_component.max_hp)
	if health_component.current_hp > 0:
		var sm := get_node("StateMachine")
		sm.on_state_transition(sm.current_state, "hurt")

func heal(amount: int) -> void:
	health_component.heal(amount)
	EventBus.player_healed.emit(health_component.current_hp, health_component.max_hp)

func apply_pickup(pickup_type: String, value: float) -> void:
	match pickup_type:
		"health":
			heal(int(value))
		"damage_up":
			stats.damage += int(value)
		"speed_up":
			stats.speed += value
	EventBus.player_stats_changed.emit(stats)

func _on_died() -> void:
	var sm := get_node("StateMachine")
	sm.on_state_transition(sm.current_state, "dead")

func _on_health_changed(_current_hp: int, _max_hp: int) -> void:
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
	
	try_attack()
