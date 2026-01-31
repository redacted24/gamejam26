extends State

@export var enemy: CharacterBody2D

func enter() -> void:
	enemy.velocity = Vector2.ZERO
	enemy.queue_free()  # Or play death animation first
