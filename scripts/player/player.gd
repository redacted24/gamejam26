extends CharacterBody2D
class_name Player

@export var health_component : HealthComponent
@export var player : CharacterBody2D

var stats := {
	speed = 200.0,
	damage = 1,
	fire_rate = 0.4,
}

var shoot_timer: Timer
var can_shoot: bool = true
var invincible: bool = false

func _ready() -> void:
	add_to_group("player")
	if NavManager:
		NavManager.player_spawn.connect(_on_spawn)
	_create_health()
	_create_shoot_timer()

func _on_spawn(spawn_location: Vector2) -> void:
	print("spawning player at %f and %f" % [spawn_location.x, spawn_location.y])
	player.position = spawn_location

func _create_health() -> void:
	health_component = get_node_or_null("HealthComponent")
	if not health_component:
		health_component = HealthComponent.new()
		health_component.name = "HealthComponent"
		add_child(health_component)
	health_component.max_hp = 6
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_on_health_changed)


func _create_shoot_timer() -> void:
	shoot_timer = get_node_or_null("ShootTimer")
	if not shoot_timer:
		shoot_timer = Timer.new()
		shoot_timer.wait_time = stats.fire_rate
		shoot_timer.one_shot = true
		shoot_timer.name = "ShootTimer"
		add_child(shoot_timer)
	shoot_timer.timeout.connect(func(): can_shoot = true)

func try_shoot() -> void:
	if not can_shoot:
		return
	if not Input.is_action_pressed("shoot"):
		return
	var shoot_dir := _get_shoot_direction()
	_fire_projectile(shoot_dir)

func _get_shoot_direction() -> Vector2:
	var mouse_pos := get_global_mouse_position()
	return (mouse_pos - global_position).normalized()

func _fire_projectile(dir: Vector2) -> void:
	can_shoot = false
	shoot_timer.start()

	var proj := Projectile.new()
	proj.setup(dir, stats.damage, 300.0, true)
	proj.global_position = global_position + dir * 20.0
	get_tree().current_scene.add_child(proj)

func take_damage(amount: int) -> void:
	if invincible:
		return
	health_component.take_damage(amount)
	EventBus.player_damaged.emit(health_component.current_hp, health_component.max_hp)
	if health_component.current_hp > 0:
		var sm := get_node("StateMachine")
		sm.on_state_transition(sm.current_state, "hurt")

func heal(amount: int) -> void:
	health_component.heal(amount)
	EventBus.player_healed.emit(health_component.current_hp, health_component.max_hp)

func apply_pickup(pickup_type: String, value: float) -> void:
	match pickup_type:
		"health":
			heal(int(value))
		"damage_up":
			stats.damage += int(value)
		"speed_up":
			stats.speed += value
	EventBus.player_stats_changed.emit(stats)

func _on_died() -> void:
	var sm := get_node("StateMachine")
	sm.on_state_transition(sm.current_state, "dead")

func _on_health_changed(_current_hp: int, _max_hp: int) -> void:
	pass
