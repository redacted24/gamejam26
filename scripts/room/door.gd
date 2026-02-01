extends Area2D
class_name Door

var next_level = {
	"path": "",
	"spawnpoint": "",
	"type": MapGeneration.room_types
}

var next_level_path : String
var next_level_spawnpoint : String
var next_level_type : MapGeneration.room_types

func _ready() -> void:
	get_node("ColorRect").queue_free()
	pass

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	# In multiplayer, only the host processes door transitions
	if NetworkManager.is_online() and not multiplayer.is_server():
		return

	print("Door entered: switching rooms to %s" % next_level.path)
	EventBus.room_cleared.emit(next_level.type)

	# Sync transition to client in multiplayer
	if NetworkManager.is_online():
		_sync_door_transition.rpc(next_level.path, next_level.spawnpoint, int(next_level.type))

	if NavManager:
		NavManager.go_to_level(next_level.path, next_level.spawnpoint)

@rpc("authority", "call_remote", "reliable")
func _sync_door_transition(path: String, spawnpoint: String, type: int) -> void:
	EventBus.room_cleared.emit(type)
	if NavManager:
		NavManager.go_to_level(path, spawnpoint)
