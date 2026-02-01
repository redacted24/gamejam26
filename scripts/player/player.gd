extends CharacterBody2D
class_name Player

enum WeaponType { BOW, SPEAR, SWORD }

const WEAPON_SCENES := {
	WeaponType.BOW: preload("res://scenes/weapons/bow_weapon.tscn"),
	WeaponType.SPEAR: preload("res://scenes/weapons/spear_weapon.tscn"),
	WeaponType.SWORD: preload("res://scenes/weapons/sword_weapon.tscn"),
}

@onready var health_component: HealthComponent = $HealthComponent

var peer_id: int = 1  # Multiplayer peer id owning this player
var aim_direction: Vector2 = Vector2.RIGHT  # Synced for remote players

var stats := {
	speed = 200.0,
	damage = 1,
}

var current_weapon: WeaponBase
var weapon_type: WeaponType = WeaponType.BOW  # Overridden in _ready from PlayerData
var invincible: bool = false
var last_hit_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	if NavManager:
		NavManager.player_spawn.connect(_on_spawn)
	EventBus.player_hunger_reduced.connect(_hunger_reduce)
	#if health_component:
		#health_component.died.connect(_on_died)
	weapon_type = PlayerData.selected_weapon as WeaponType
	_equip_weapon(weapon_type)
	if CosmeticsData:
		$AnimatedSprite2D.modulate = CosmeticsData.selected_color

func _hunger_reduce(amount: int) -> void:
	PlayerData.hunger -= amount
	print("hunger amount is onw %d" % PlayerData.hunger)
	EventBus.refresh_ui.emit()
	if PlayerData.hunger <= 0:
		EventBus.player_died.emit()

func _on_spawn(spawn_location: Vector2) -> void:
	if NetworkManager.is_online():
		var peer_ids := NetworkManager.get_peer_ids()
		var idx := peer_ids.find(peer_id)
		if idx == -1:
			idx = 0
		position = spawn_location + Vector2(idx * 30, 0)
	else:
		position = spawn_location

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

func take_damage(amount: int, hit_position: Vector2 = Vector2.ZERO) -> void:
	if invincible:
		return
	last_hit_position = hit_position
	health_component.take_damage(amount)
	EventBus.player_damaged.emit(peer_id, health_component.current_hp, health_component.max_hp)
	if health_component.current_hp > 0:
		var sm := get_node("StateMachine")
		sm.on_state_transition(sm.current_state, "hurt")

func heal(amount: int) -> void:
	health_component.heal(amount)
	EventBus.player_healed.emit(peer_id, health_component.current_hp, health_component.max_hp)

func apply_pickup(pickup_type: String, value: float) -> void:
	match pickup_type:
		"health":
			heal(int(value))
		"damage_up":
			stats.damage += int(value)
		"speed_up":
			stats.speed += value
		"food":
			PlayerData.hunger = mini(PlayerData.hunger + int(value), PlayerData.max_hunger)
			EventBus.refresh_ui.emit()
	EventBus.player_stats_changed.emit(peer_id, stats)

func _on_died() -> void:
	_do_death()
	if NetworkManager.is_online():
		_sync_death.rpc()

func _do_death() -> void:
	var sm := get_node("StateMachine")
	sm.on_state_transition(sm.current_state, "dead")
	EventBus.player_died.emit(peer_id)

@rpc("any_peer", "call_remote", "reliable")
func _sync_death() -> void:
	_do_death()

func _on_health_changed(_current_hp: int, _max_hp: int) -> void:
	pass
