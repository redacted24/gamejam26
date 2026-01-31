extends Node

# Player signals
signal player_damaged(current_hp: int, max_hp: int)
signal player_healed(current_hp: int, max_hp: int)
signal player_died
signal player_stats_changed(stats: Dictionary)
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
