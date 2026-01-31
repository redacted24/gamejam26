extends CharacterBody2D
class_name Player

var stats := {
	speed = 200.0,
	damage = 1,
	fire_rate = 0.4,
}

var health_component: HealthComponent
var shoot_timer: Timer
var can_shoot: bool = true
var invincible: bool = false

func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1

	_create_collision()
	_create_visual()
	_create_health()
	_create_shoot_timer()
	_create_state_machine()

func _create_collision() -> void:
	var col := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 12.0
	col.shape = circle
	add_child(col)

func _create_visual() -> void:
	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([
		Vector2(0, -16),
		Vector2(-12, 12),
		Vector2(12, 12),
	])
	visual.color = Color.WHITE
	visual.name = "Visual"
	add_child(visual)

func _create_health() -> void:
	health_component = HealthComponent.new()
	health_component.max_hp = 6
	health_component.name = "HealthComponent"
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_on_health_changed)
	add_child(health_component)

func _create_shoot_timer() -> void:
	shoot_timer = Timer.new()
	shoot_timer.wait_time = stats.fire_rate
	shoot_timer.one_shot = true
	shoot_timer.name = "ShootTimer"
	shoot_timer.timeout.connect(func(): can_shoot = true)
	add_child(shoot_timer)

func _create_state_machine() -> void:
	var sm_script := preload("res://scripts/state_machine.gd")
	var sm := Node.new()
	sm.set_script(sm_script)
	sm.name = "StateMachine"

	var idle := Node.new()
	idle.set_script(preload("res://scripts/player/player_idle_state.gd"))
	idle.name = "Idle"
	sm.add_child(idle)

	var move := Node.new()
	move.set_script(preload("res://scripts/player/player_move_state.gd"))
	move.name = "Move"
	sm.add_child(move)

	var hurt := Node.new()
	hurt.set_script(preload("res://scripts/player/player_hurt_state.gd"))
	hurt.name = "Hurt"
	sm.add_child(hurt)

	var dead := Node.new()
	dead.set_script(preload("res://scripts/player/player_dead_state.gd"))
	dead.name = "Dead"
	sm.add_child(dead)

	sm.initial_state = idle
	add_child(sm)

func try_shoot() -> void:
	if not can_shoot:
		return
	var shoot_dir := _get_shoot_direction()
	if shoot_dir == Vector2.ZERO:
		return
	_fire_projectile(shoot_dir)

func _get_shoot_direction() -> Vector2:
	if Input.is_action_pressed("shoot_up"):
		return Vector2.UP
	if Input.is_action_pressed("shoot_down"):
		return Vector2.DOWN
	if Input.is_action_pressed("shoot_left"):
		return Vector2.LEFT
	if Input.is_action_pressed("shoot_right"):
		return Vector2.RIGHT
	return Vector2.ZERO

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
