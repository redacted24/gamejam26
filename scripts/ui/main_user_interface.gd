extends CanvasLayer

@export var hunger_label : Label

func _ready() -> void:
	update_hunger_label()
	EventBus.player_hunger_reduced.connect(_on_player_hunger_reduced)
	
# Fetches the player data for hunger and max hunger from PlayerData and updates label
func update_hunger_label() -> void:
	hunger_label.text = "Hunger: %d / %d" % [PlayerData.hunger, PlayerData.max_hunger]
	pass
	
func _on_player_hunger_reduced(amount : int) -> void:
	call_deferred("update_hunger_label")
	pass
	
func process() -> void:
	pass
	
func _exit_tree() -> void:
	pass
