extends WeaponBase
class_name SpearWeapon

@export var attack_duration: float = 0.15
@export var thrust_distance: float = 50.0

@onready var hitbox: Area2D = $Hitbox

var _hit_targets: Array[Node2D] = []
var _thrust_tween: Tween

# Upgrades
var has_long_reach: bool = false
var has_double_thrust: bool = false
var has_lunge: bool = false

func _ready() -> void:
	super._ready()
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	_set_hitbox_enabled(false)
	_apply_upgrades()

func _apply_upgrades() -> void:
	has_long_reach = PlayerData.has_upgrade("spear_long_reach")
	has_double_thrust = PlayerData.has_upgrade("spear_double_thrust")
	has_lunge = PlayerData.has_upgrade("spear_lunge")
	if has_long_reach:
		thrust_distance *= 2.5

func _process(_delta: float) -> void:
	_update_aim()

func _perform_attack(_dir: Vector2) -> void:
	super._perform_attack(_dir)
	if has_lunge and player:
		var lunge_tween := create_tween()
		lunge_tween.tween_property(player, "global_position", player.global_position + _dir * 60.0, attack_duration * 0.4).set_ease(Tween.EASE_OUT)
	_do_thrust()
	if NetworkManager.is_online():
		_do_thrust_remote.rpc()

func _do_thrust() -> void:
	_hit_targets.clear()
	_set_hitbox_enabled(true)

	if _thrust_tween and _thrust_tween.is_valid():
		_thrust_tween.kill()

	_thrust_tween = create_tween()
	_thrust_tween.tween_property(sprite, "position:x", thrust_distance, attack_duration * 0.4).set_ease(Tween.EASE_OUT)
	_thrust_tween.tween_property(sprite, "position:x", 0.0, attack_duration * 0.6).set_ease(Tween.EASE_IN)

	if has_double_thrust:
		_thrust_tween.tween_callback(_hit_targets.clear)
		_thrust_tween.tween_property(sprite, "position:x", thrust_distance, attack_duration * 0.4).set_ease(Tween.EASE_OUT)
		_thrust_tween.tween_property(sprite, "position:x", 0.0, attack_duration * 0.6).set_ease(Tween.EASE_IN)

	_thrust_tween.tween_callback(_set_hitbox_enabled.bind(false))

@rpc("any_peer", "call_remote", "reliable")
func _do_thrust_remote() -> void:
	_do_thrust()

func _set_hitbox_enabled(enabled: bool) -> void:
	hitbox.monitoring = enabled
	hitbox.set_deferred("monitorable", enabled)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body in _hit_targets:
		return
	_hit_targets.append(body)

	if body.has_method("take_damage"):
		# Only host processes damage to enemies
		if body.is_in_group("enemies"):
			if NetworkManager.is_online() and not multiplayer.is_server():
				return
		body.take_damage(damage, global_position)
