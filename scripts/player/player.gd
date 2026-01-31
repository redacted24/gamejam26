extends CharacterBody2D
class_name Player

enum WeaponType { BOW, SPEAR }

const WEAPON_SCENES := {
	WeaponType.BOW: preload("res://scenes/weapons/bow_weapon.tscn"),
	WeaponType.SPEAR: preload("res://scenes/weapons/spear_weapon.tscn"),
}

var stats := {
	speed = 200.0,
	damage = 1,
	attack_rate = 0.6,
}

var health_component: HealthComponent
var current_weapon: WeaponBase
var weapon_type: WeaponType = WeaponType.BOW
var invincible: bool = false

func _ready() -> void:
	_create_health()
	_equip_weapon(weapon_type)

func _create_health() -> void:
	health_component = HealthComponent.new()
	health_component.max_hp = 6
	health_component.name = "HealthComponent"
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_on_health_changed)
	add_child(health_component)

func _equip_weapon(type: WeaponType) -> void:
	if current_weapon:
		current_weapon.queue_free()

	var weapon_scene: PackedScene = WEAPON_SCENES[type]
	current_weapon = weapon_scene.instantiate()
	current_weapon.damage = stats.damage
	current_weapon.setup(self)
	add_child(current_weapon)
	weapon_type = type

func switch_weapon(type: WeaponType) -> void:
	_equip_weapon(type)

func try_attack() -> void:
	if current_weapon:
		current_weapon.try_attack()

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
