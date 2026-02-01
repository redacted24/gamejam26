extends Node

var max_hunger : int
var hunger : int

var max_hitpoints : int
var hitpoints : int

var selected_weapon : int = 0  # Maps to Player.WeaponType: 0=BOW, 1=SPEAR, 2=SWORD
var kills : int

var post_tutorial_shown : bool = false

# initialize all values for players
func _ready() -> void:
	max_hunger = 150
	hunger = max_hunger
	
	max_hitpoints = 10
	hitpoints = max_hitpoints
