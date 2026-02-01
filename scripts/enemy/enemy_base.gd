extends CharacterBody2D
class_name EnemyBase

@export var speed: float = 100.0
@export var contact_damage: int = 1
@export var max_hp: int = 3

@export_group("Drops")
@export var drop_enabled: bool = true
@export var drop_type: String = "food"
@export var drop_value: float = 5.0
@export var drop_texture: Texture2D = preload("res://assets/items/meat.png")
@export var drop_scale: float = 0.45
@export var drop_attract_radius: float = 80.0

@onready var health_component: HealthComponent = $HealthComponent

var _sync_timer: float = 0.0
var _last_pos: Vector2 = Vector2.ZERO
const SYNC_RATE: float = 0.0167  # 60 Hz

func _ready() -> void:
	add_to_group("enemies")
	health_component.max_hp = max_hp
	health_component.died.connect(_on_died)

	if NetworkManager.is_online():
		set_multiplayer_authority(1)  # Host owns all enemies
		if not multiplayer.is_server():
			# Client: disable AI, positions come from host
			var sm := get_node_or_null("StateMachine")
			if sm:
				sm.process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta: float) -> void:
	if not NetworkManager.is_online():
		return
	if multiplayer.is_server():
		_sync_timer += delta
		if _sync_timer >= SYNC_RATE:
			_sync_timer = 0.0
			var visual := get_node_or_null("AnimatedSprite2D")
			var rot: float = visual.rotation if visual else 0.0
			var flip: bool = visual.flip_h if visual else false
			_sync_state.rpc(global_position, rot, flip)
	else:
		_last_pos = global_position

@rpc("authority", "call_remote", "unreliable")
func _sync_state(pos: Vector2, sprite_rot: float, sprite_flip: bool) -> void:
	global_position = pos
	var visual := get_node_or_null("AnimatedSprite2D")
	if visual:
		visual.rotation = sprite_rot
		visual.flip_h = sprite_flip

func _on_died() -> void:
	_drop_meat()
	EventBus.enemy_died.emit()
	if NetworkManager.is_online() and multiplayer.is_server():
		_remote_die.rpc()
	queue_free()

func _drop_meat() -> void:
	if not drop_enabled:
		return
	var pickup := Pickup.new()
	pickup.pickup_type = drop_type
	pickup.value = drop_value
	pickup._visual_texture = drop_texture
	pickup._visual_scale = drop_scale
	pickup.attract_radius = drop_attract_radius
	pickup.position = global_position
	get_tree().current_scene.call_deferred("add_child", pickup)

@rpc("authority", "call_remote", "reliable")
func _remote_die() -> void:
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

	_show_damage_flash()
	if NetworkManager.is_online() and multiplayer.is_server():
		_remote_damage_flash.rpc()

func _show_damage_flash() -> void:
	var visual := get_node_or_null("AnimatedSprite2D")
	if visual and health_component.current_hp > 0:
		var tween := create_tween()
		tween.tween_property(visual, "modulate", Color.WHITE, 0.15).from(Color.RED)

@rpc("authority", "call_remote", "reliable")
func _remote_damage_flash() -> void:
	_show_damage_flash()

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
