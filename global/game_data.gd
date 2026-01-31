extends Node

var current_floor: int = 1
var rooms_cleared: Array[int] = []
var run_active: bool = false

func reset_run() -> void:
	current_floor = 1
	rooms_cleared.clear()
	run_active = true

func mark_room_cleared(room_id: int) -> void:
	if room_id not in rooms_cleared:
		rooms_cleared.append(room_id)
		# Sync to client in multiplayer
		if NetworkManager.is_online() and multiplayer.is_server():
			_sync_room_cleared.rpc(room_id)

func is_room_cleared(room_id: int) -> bool:
	return room_id in rooms_cleared

@rpc("authority", "call_remote", "reliable")
func _sync_room_cleared(room_id: int) -> void:
	if room_id not in rooms_cleared:
		rooms_cleared.append(room_id)
