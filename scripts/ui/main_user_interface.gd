extends CanvasLayer

# Main control node
@export var control_node : Control

# Individual items
@export var hunger_label : Label
@export var hitpoints_label : Label

func _ready() -> void:
	# initially hide the game ui elements
	control_node.hide()
	update_hunger_label()
	update_hitpoints_label()
	EventBus.player_hunger_reduced.connect(_on_player_hunger_reduced)
	EventBus.player_damaged.connect(_on_player_damaged)
	EventBus.game_started.connect(_on_game_started)
	
func _on_game_started() -> void:
	control_node.show()
	pass
	
# Fetches the player data for hunger and max hunger from PlayerData and updates label
func update_hunger_label() -> void:
	hunger_label.text = "Hunger: %d / %d" % [PlayerData.hunger, PlayerData.max_hunger]
	
func _on_player_hunger_reduced(amount : int) -> void:
	call_deferred("update_hunger_label")

# Fetches the player data for hitpoints and max hitpoints from PlayerData and updates data
func update_hitpoints_label() -> void:
	hitpoints_label.text = "HP: %d / %d" % [PlayerData.hitpoints, PlayerData.max_hitpoints]
	
func _on_player_damaged(amount : int) -> void:
	call_deferred("update_hitpoints_label")
	
func process() -> void:
	pass
	
func _exit_tree() -> void:
	pass
