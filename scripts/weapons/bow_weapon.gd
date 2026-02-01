extends WeaponBase
class_name BowWeapon

enum ChargeState { IDLE, CHARGE_1, CHARGE_2, BOW_DRAWN }

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 300.0
@export var min_charge_time: float = 0.33
@export var max_charge_time: float = 1.0
@export var min_damage_multiplier: float = 1.0
@export var max_damage_multiplier: float = 5.0
@export var min_speed_multiplier: float = 1.0
@export var max_speed_multiplier: float = 3.0

@export_group("Bow Sprites")
@export var sprite_idle: Texture2D
@export var sprite_charge_1: Texture2D
@export var sprite_charge_2: Texture2D
@export var sprite_bow_drawn: Texture2D

var is_charging: bool = false
var charge_time: float = 0.0
var charge_state: ChargeState = ChargeState.IDLE

# Upgrades
var has_multishot: bool = false
var has_piercing: bool = false
var has_quick_draw: bool = false
var _charge_midpoint: float = 0.66

func _ready() -> void:
	super._ready()
	_apply_upgrades()
	_update_sprite()

func _apply_upgrades() -> void:
	has_multishot = PlayerData.has_upgrade("bow_multishot")
	has_piercing = PlayerData.has_upgrade("bow_piercing")
	has_quick_draw = PlayerData.has_upgrade("bow_quick_draw")
	if has_quick_draw:
		min_charge_time *= 0.5
		max_charge_time *= 0.5
	_charge_midpoint = (min_charge_time + max_charge_time) / 2.0

func _process(delta: float) -> void:
	_update_aim()

	if not player or (NetworkManager.is_online() and not player.is_multiplayer_authority()):
		return

	if Input.is_action_pressed("shoot"):
		if not is_charging:
			is_charging = true
			charge_time = 0.0
		else:
			charge_time = minf(charge_time + delta, max_charge_time)
		_update_charge_state()
	elif is_charging:
		_fire_charged_arrow()
		is_charging = false
		charge_time = 0.0
		charge_state = ChargeState.IDLE
		_update_sprite()

func _update_charge_state() -> void:
	var new_state: ChargeState

	if charge_time < min_charge_time:
		new_state = ChargeState.IDLE
	elif charge_time < _charge_midpoint:
		new_state = ChargeState.CHARGE_1
	elif charge_time < max_charge_time:
		new_state = ChargeState.CHARGE_2
	else:
		new_state = ChargeState.BOW_DRAWN

	if new_state != charge_state:
		charge_state = new_state
		_update_sprite()

func _update_sprite() -> void:
	if not sprite:
		return

	match charge_state:
		ChargeState.IDLE:
			sprite.texture = sprite_idle
		ChargeState.CHARGE_1:
			sprite.texture = sprite_charge_1
		ChargeState.CHARGE_2:
			sprite.texture = sprite_charge_2
		ChargeState.BOW_DRAWN:
			sprite.texture = sprite_bow_drawn

func _fire_charged_arrow() -> void:
	if charge_time < min_charge_time:
		return

	var charge_ratio := (charge_time - min_charge_time) / (max_charge_time - min_charge_time)
	charge_ratio = clampf(charge_ratio, 0.0, 1.0)
	var dir := _get_attack_direction()
	var final_damage := int(damage * lerpf(min_damage_multiplier, max_damage_multiplier, charge_ratio))
	var final_speed := projectile_speed * lerpf(min_speed_multiplier, max_speed_multiplier, charge_ratio)
	var spawn_pos := player.global_position + dir * 20.0

	if has_multishot:
		var spread := deg_to_rad(10.0)
		var dir_left := dir.rotated(-spread)
		var dir_right := dir.rotated(spread)
		_spawn_arrow(dir_left, final_damage, final_speed, spawn_pos)
		_spawn_arrow(dir_right, final_damage, final_speed, spawn_pos)
		if NetworkManager.is_online():
			_spawn_arrow_remote.rpc(dir_left, final_damage, final_speed, spawn_pos)
			_spawn_arrow_remote.rpc(dir_right, final_damage, final_speed, spawn_pos)
	else:
		_spawn_arrow(dir, final_damage, final_speed, spawn_pos)
		if NetworkManager.is_online():
			_spawn_arrow_remote.rpc(dir, final_damage, final_speed, spawn_pos)

func _spawn_arrow(dir: Vector2, dmg: int, spd: float, pos: Vector2) -> void:
	var proj: Projectile = projectile_scene.instantiate()
	proj.setup(dir, dmg, spd, true, player.peer_id)
	proj.piercing = has_piercing
	proj.global_position = pos
	player.get_tree().current_scene.add_child(proj)

@rpc("any_peer", "call_remote", "reliable")
func _spawn_arrow_remote(dir: Vector2, dmg: int, spd: float, pos: Vector2) -> void:
	_spawn_arrow(dir, dmg, spd, pos)

func try_attack() -> void:
	pass
