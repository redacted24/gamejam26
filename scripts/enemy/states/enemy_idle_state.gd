extends State

@export var enemy: CharacterBody2D

func enter() -> void:
	enemy.velocity = Vector2.ZERO

func physics_process(_delta: float) -> void:
	pass  # Just stand still
