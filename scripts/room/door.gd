extends Area2D
class_name Door

@onready var hunger_reduction_label = $Control/Gamejam2026UiDialogueBox/Label
@onready var ui_popup = $Control

var next_level = {
	"path": "",
	"spawnpoint": "",
	"type": null
}

func _ready() -> void:
	get_node("ColorRect").queue_free()
	ui_popup.hide()

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	# In multiplayer, only the host processes door transitions
	if NetworkManager.is_online() and not multiplayer.is_server():
		return

	# Block entry if player doesn't have enough hunger
	var cost := _get_hunger_cost()
	if PlayerData.hunger < cost:
		return

	# Sync transition to client in multiplayer
	if NetworkManager.is_online():
		_sync_door_transition.rpc(next_level.path, next_level.spawnpoint, int(next_level.type))

	print("Door entered: switching rooms to %s" % next_level.path)
	EventBus.room_cleared.emit(next_level.type)
	if NavManager:
		NavManager.go_to_level(next_level.path, next_level.spawnpoint)

@rpc("authority", "call_remote", "reliable")
func _sync_door_transition(path: String, spawnpoint: String, type: int) -> void:
	EventBus.room_cleared.emit(type)
	if NavManager:
		NavManager.go_to_level(path, spawnpoint)
		
func _get_hunger_cost() -> int:
	if next_level.type == MapGeneration.room_types.COMBAT_ROOM or next_level.type == MapGeneration.room_types.CROSSROADS_ROOM:
		return 20
	elif next_level.type == MapGeneration.room_types.PEACEFUL_ROOM:
		return 10
	return 0

func _on_interactable_area_entered(body: Node2D) -> void:
	var hunger := _get_hunger_cost()
	hunger_reduction_label.text = "- %d" % hunger
	ui_popup.show()

func _on_interactable_area_leave(body: Node2D) -> void:
	ui_popup.hide()
