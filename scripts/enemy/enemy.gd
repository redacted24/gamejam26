extends CharacterBody2D
class_name EnemyBase

@export var health_component : HealthComponent
@export var speed: float = 100.0
@export var contact_damage: int = 1

var _max_hp: int = 3

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	health_component.died.connect(_on_died)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and body.is_in_group("player"):
		body.take_damage(contact_damage)

func _on_died() -> void:
	EventBus.enemy_died.emit(global_position)
	var sm := get_node_or_null("StateMachine")
	if sm and sm.states.has("dead"):
		sm.on_state_transition(sm.current_state, "dead")
	else:
		queue_free()

func take_damage(amount: int) -> void:
	print("enemy took damage %d" % amount)
	health_component.take_damage(amount)
	var visual := get_node_or_null("Visual")
	if visual and health_component.current_hp > 0:
		var tween := create_tween()
		tween.tween_property(visual, "modulate", Color.WHITE, 0.15).from(Color.RED)

func get_player() -> Node2D:
	return get_tree().get_first_node_in_group("player")
