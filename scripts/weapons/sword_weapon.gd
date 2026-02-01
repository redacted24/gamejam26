extends WeaponBase
class_name SwordWeapon

@export var attack_duration: float = 0.3
@export var swing_arc: float = 120.0  # Total arc in degrees the hitbox sweeps

@onready var idle_sprite: Sprite2D = $IdleSprite
@onready var swing_sprite: AnimatedSprite2D = $SwingSprite
@onready var hitbox: Area2D = $Hitbox

var _hit_targets: Array[Node2D] = []
var _is_attacking: bool = false
var _swing_tween: Tween
var _is_first_swing: bool = true

# Upgrades
var has_knockback: bool = false
var has_fire_aspect: bool = false
var has_whirlwind: bool = false

func _ready() -> void:
	super._ready()
	sprite = idle_sprite
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	swing_sprite.animation_finished.connect(_on_swing_finished)
	_set_hitbox_enabled(false)
	_show_idle()
	_apply_upgrades()

func _apply_upgrades() -> void:
	has_knockback = PlayerData.has_upgrade("sword_knockback")
	has_fire_aspect = PlayerData.has_upgrade("sword_fire_aspect")
	has_whirlwind = PlayerData.has_upgrade("sword_whirlwind")

func _process(_delta: float) -> void:
	_update_aim()

func _perform_attack(_dir: Vector2) -> void:
	if _is_attacking:
		return
	super._perform_attack(_dir)
	_hit_targets.clear()
	_is_attacking = true
	_is_first_swing = true
	_set_hitbox_enabled(true)
	_start_hitbox_swing()
	_show_swing()

func _start_hitbox_swing() -> void:
	if _swing_tween and _swing_tween.is_valid():
		_swing_tween.kill()
	var facing_left := sprite.flip_v if sprite else false
	var start_deg := 135.0 if facing_left else -135.0
	var end_deg := -135.0 if facing_left else 135.0
	hitbox.rotation = deg_to_rad(start_deg)
	_swing_tween = create_tween()
	_swing_tween.tween_property(hitbox, "rotation", deg_to_rad(end_deg), attack_duration).set_ease(Tween.EASE_OUT)

func _start_return_swing() -> void:
	if _swing_tween and _swing_tween.is_valid():
		_swing_tween.kill()
	var facing_left := sprite.flip_v if sprite else false
	var start_deg := -135.0 if facing_left else 135.0
	var end_deg := 135.0 if facing_left else -135.0
	hitbox.rotation = deg_to_rad(start_deg)
	_swing_tween = create_tween()
	_swing_tween.tween_property(hitbox, "rotation", deg_to_rad(end_deg), attack_duration).set_ease(Tween.EASE_OUT)

func _show_idle() -> void:
	idle_sprite.visible = true
	swing_sprite.visible = false
	hitbox.rotation = 0.0

func _show_swing() -> void:
	idle_sprite.visible = false
	swing_sprite.visible = true
	swing_sprite.play("swing")

func _on_swing_finished() -> void:
	if has_whirlwind and _is_first_swing:
		_is_first_swing = false
		_hit_targets.clear()
		_start_return_swing()
		swing_sprite.play("swing")
		return
	_is_attacking = false
	_set_hitbox_enabled(false)
	if _swing_tween and _swing_tween.is_valid():
		_swing_tween.kill()
	_show_idle()

func _set_hitbox_enabled(enabled: bool) -> void:
	hitbox.monitoring = enabled
	hitbox.set_deferred("monitorable", enabled)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body in _hit_targets:
		return
	_hit_targets.append(body)

	if body.has_method("take_damage"):
		body.take_damage(damage, global_position)

	if body.is_in_group("enemies"):
		if has_knockback:
			var knockback_dir := (body.global_position - global_position).normalized()
			var sm := body.get_node_or_null("StateMachine")
			if sm and sm.current_state and sm.current_state.has_method("apply_knockback"):
				sm.current_state.apply_knockback(knockback_dir, 500.0)

		#if has_fire_aspect:
		#	if not body.has_node("BurnEffect"):
		#		var burn := BurnEffect.new()
		#		burn.name = "BurnEffect"
		#		burn.setup(1, 0.5, 2.0)
		#		body.add_child(burn)
