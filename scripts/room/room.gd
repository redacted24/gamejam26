extends Node2D
class_name Room

@export var room_type : MapGeneration.room_types
@export var hunger_cost : int

var enemy_count : int
var door_count : int
var is_cleared : bool
var all_doors : Array # array holds all doors (exits)

func _ready() -> void:
	# Reduce player hunger by the amount specified
	EventBus.player_hunger_reduced.emit(hunger_cost)
	is_cleared = false
	# Connect spawn location signal
	if NavManager and NavManager.spawn_location != null:
		_on_level_spawn(NavManager.spawn_location)
		
	assign_doors()

# Function that assigns door
func assign_doors() -> void:
	# Get all door nodes
	all_doors = get_node("Doors").get_children()
	door_count = all_doors.size()
	# iterate through doors and assign their teleport
	for door : Door in all_doors:
		var next_room = MapGeneration.generate_next_rooms()
		door.next_level.path = next_room.path
		door.next_level.type = next_room.type
		# all rooms should only have one spawnpoint for now
		door.next_level.spawnpoint = "Main"
		#print("a door connects to %s" % next_room[0])
		
func spawn_enemies() -> void:
	pass
	
# Function that determines where the player should spawn
# Emits the signal for the player to spawn
func _on_level_spawn(spawn_location : String) -> void:
	var spawn_path = "SpawnPoints/" + spawn_location
	var spawn : Node2D = get_node(spawn_path)
	NavManager.trigger_player_spawn(spawn.global_position)
