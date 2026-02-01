extends Node

var max_hunger : int
var hunger : int

var max_hitpoints : int
var hitpoints : int

var selected_weapon : int = 0  # Maps to Player.WeaponType: 0=BOW, 1=SPEAR, 2=SWORD
var kills : int = 0
var pickups : int = 0

var post_tutorial_shown : bool = false
var death_reason : String = ""

var upgrades: Dictionary = {}

func grant_upgrade(upgrade_name: String) -> void:
	upgrades[upgrade_name] = true

func has_upgrade(upgrade_name: String) -> bool:
	return upgrades.has(upgrade_name)

func reset_upgrades() -> void:
	upgrades.clear()

func reset() -> void:
	max_hunger = 150
	hunger = 35
	max_hitpoints = 10
	hitpoints = max_hitpoints
	kills = 0
	pickups = 0
	death_reason = ""
	upgrades.clear()

# initialize all values for players
func _ready() -> void:
	# Signals
	EventBus.pickup_collected.connect(_on_pickup_collect)
	EventBus.enemy_died.connect(_on_enemy_died)
	max_hunger = 150
	hunger = 35
	
	max_hitpoints = 10
	hitpoints = max_hitpoints

func _on_pickup_collect() -> void:
	pickups += 1

func _on_enemy_died() -> void:
	kills += 1
