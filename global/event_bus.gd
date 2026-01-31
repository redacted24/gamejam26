extends Node

# Player signals (peer_id identifies which player)
signal player_damaged(peer_id: int, current_hp: int, max_hp: int)
signal player_healed(peer_id: int, current_hp: int, max_hp: int)
signal player_died(peer_id: int)
signal player_stats_changed(peer_id: int, stats: Dictionary)
signal player_entered_door(direction: Vector2i)

# Enemy signals
signal enemy_died(pos: Vector2)
signal enemy_spawned

# Room signals
signal room_entered(room_data: Dictionary)
signal room_cleared
signal floor_completed

# Pickup signals
signal pickup_collected(pickup_type: String, value: float)

# Game flow signals
signal restart_requested
