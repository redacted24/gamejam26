extends Node

# Player signals
signal player_hunger_reduced(amount : int)
#signal player_damaged(current_hp: int, max_hp: int)
#signal player_healed(current_hp: int, max_hp: int)
signal player_died
#signal player_stats_changed(stats: Dictionary)
#signal player_entered_door(direction: Vector2i)

# Enemy signals
#signal enemy_died(pos: Vector2)
#signal enemy_spawned

# Room signals
signal room_cleared(next_level_type : MapGeneration.room_types)

# Pickup signals
#signal pickup_collected(pickup_type: String, value: float)

# Game flow signals
#signal restart_requested
