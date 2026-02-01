extends CanvasLayer

# Main control node
@export var control_node : Control

# Individual items
@export var hunger_label : Label
@export var hitpoints_label : Label
@export var hp_bar : ColorRect
@export var hunger_bar : ColorRect

const BAR_MAX_WIDTH := 234.0

func _ready() -> void:
	# initially hide the game ui elements
	control_node.hide()
	update_hunger_label()
	update_hunger_bar()
	update_hitpoints_label()
	update_hitpoints_bar()
	
	# Signals
	EventBus.refresh_ui.connect(_on_ui_refresh)
	EventBus.game_started.connect(_on_game_started)
	
func _on_game_started() -> void:
	control_node.show()
	pass
	
# Fetches the player data for hunger and max hunger from PlayerData and updates label
func update_hunger_label() -> void:
	hunger_label.text = "%d / %d" % [PlayerData.hunger, PlayerData.max_hunger]

# Updates the hunger bar size based on current/max ratio
func update_hunger_bar() -> void:
	if not hunger_bar or PlayerData.max_hunger <= 0:
		return
	var ratio := clampf(float(PlayerData.hunger) / float(PlayerData.max_hunger), 0.0, 1.0)
	hunger_bar.size.x = BAR_MAX_WIDTH * ratio

# Fetches the player data for hitpoints and max hitpoints from PlayerData and updates data
func update_hitpoints_label() -> void:
	hitpoints_label.text = "%d / %d" % [PlayerData.hitpoints, PlayerData.max_hitpoints]

# Updates the HP bar size based on current/max ratio
func update_hitpoints_bar() -> void:
	if not hp_bar or PlayerData.max_hitpoints <= 0:
		return
	var ratio := clampf(float(PlayerData.hitpoints) / float(PlayerData.max_hitpoints), 0.0, 1.0)
	hp_bar.size.x = BAR_MAX_WIDTH * ratio

# Called when a signal to refresh ui is made
func _on_ui_refresh() -> void:
	update_hunger_label()
	update_hunger_bar()
	update_hitpoints_label()
	update_hitpoints_bar()
	
func process() -> void:
	pass
	
func _exit_tree() -> void:
	pass
