extends CharacterBody2D
class_name EnemyBase

@export var speed: float = 100.0
@export var contact_damage: int = 1
var _max_hp: int = 3

var health_component: HealthComponent

func _ready() -> void:
	add_to_group("enemies")
	collision_layer = 4
	collision_mask = 1

	_create_collision()
	_create_visual()
	_create_health()
	_create_hitbox()
	_create_state_machine()

func _create_collision() -> void:
	var col := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 14.0
	col.shape = circle
	add_child(col)

func _create_visual() -> void:
	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([
		Vector2(-14, -14), Vector2(14, -14),
		Vector2(14, 14), Vector2(-14, 14),
	])
	visual.color = Color.DARK_RED
	visual.name = "Visual"
	add_child(visual)

func _create_health() -> void:
	health_component = HealthComponent.new()
	health_component.max_hp = _max_hp
	health_component.name = "HealthComponent"
	health_component.died.connect(_on_died)
	add_child(health_component)

func _create_hitbox() -> void:
	var hitbox := Area2D.new()
	hitbox.name = "Hitbox"
	hitbox.collision_layer = 0
	hitbox.collision_mask = 2
	hitbox.monitoring = true
	hitbox.monitorable = false

	var col := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 16.0
	col.shape = circle
	hitbox.add_child(col)
	add_child(hitbox)

	hitbox.body_entered.connect(_on_hitbox_body_entered)

func _create_state_machine() -> void:
	pass

func _build_state_machine(states: Array[Dictionary]) -> void:
	var sm_script := preload("res://scripts/state_machine.gd")
	var sm := Node.new()
	sm.set_script(sm_script)
	sm.name = "StateMachine"

	var first_state: Node = null
	for state_def in states:
		var state := Node.new()
		state.set_script(state_def.script)
		state.name = state_def.node_name
		if state_def.has("props"):
			for key in state_def.props:
				state.set(key, state_def.props[key])
		sm.add_child(state)
		if first_state == null:
			first_state = state

	sm.initial_state = first_state
	add_child(sm)

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
	health_component.take_damage(amount)
	var visual := get_node_or_null("Visual")
	if visual and health_component.current_hp > 0:
		var tween := create_tween()
		tween.tween_property(visual, "modulate", Color.WHITE, 0.15).from(Color.RED)

func get_player() -> Node2D:
	return get_tree().get_first_node_in_group("player")
