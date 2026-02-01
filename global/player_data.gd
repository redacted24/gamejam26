extends Node

var max_hunger : int
var hunger : int

var max_hitpoints : int
var hitpoints : int

# initialize all values for players
func _ready() -> void:
	max_hunger = 150
	hunger = max_hunger
	
	max_hitpoints = 10
	hitpoints = max_hitpoints
