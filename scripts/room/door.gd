extends Area2D
class_name Door

@onready var text = $Control/Gamejam2026UiDialogueBox/Label
@onready var ui_popup = $Control

var next_level = {
	"path": "",
	"spawnpoint": "",
	"type": MapGeneration.room_types
}

func _ready() -> void:
	get_node("ColorRect").queue_free()
	ui_popup.hide()
	pass

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	# In multiplayer, only the host processes door transitions
	if NetworkManager.is_online() and not multiplayer.is_server():
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
		
func _on_interactable_area_entered(body: Node2D) -> void:
	ui_popup.show()
	pass
