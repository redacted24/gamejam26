extends CharacterBody2D
class_name EnemyBase

@export var speed: float = 100.0
@export var contact_damage: int = 1
@export var max_hp: int = 3

@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:
	add_to_group("enemies")
	health_component.max_hp = max_hp
	health_component.died.connect(_on_died)

func _on_died() -> void:
	EventBus.enemy_died.emit(global_position)
	queue_free()

func take_damage(amount: int, from_position: Vector2 = Vector2.ZERO) -> void:
	health_component.take_damage(amount)
	
	# Apply knockback to current active state
	if from_position != Vector2.ZERO:
		var knockback_dir := (global_position - from_position).normalized()
		var sm := get_node_or_null("StateMachine")
		if sm and sm.current_state and sm.current_state.has_method("apply_knockback"):
			sm.current_state.apply_knockback(knockback_dir, 300.0)
	
	var visual := get_node_or_null("AnimatedSprite2D")
	if visual and health_component.current_hp > 0:
		var tween := create_tween()
		tween.tween_property(visual, "modulate", Color.WHITE, 0.15).from(Color.RED)

func get_player() -> Node2D:
	# Find the nearest player (supports multiplayer with 2+ players)
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	if players.size() == 1:
		return players[0]
	var nearest: Node2D = null
	var nearest_dist := INF
	for p in players:
		var dist := global_position.distance_squared_to(p.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = p
	return nearest
