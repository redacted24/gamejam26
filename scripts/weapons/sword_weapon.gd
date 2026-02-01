extends WeaponBase
class_name SwordWeapon

@export var attack_duration: float = 0.3

@onready var idle_sprite: Sprite2D = $IdleSprite
@onready var swing_sprite: AnimatedSprite2D = $SwingSprite
@onready var hitbox: Area2D = $Hitbox

var _hit_targets: Array[Node2D] = []
var _is_attacking: bool = false

func _ready() -> void:
	super._ready()
	sprite = idle_sprite
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	swing_sprite.animation_finished.connect(_on_swing_finished)
	_set_hitbox_enabled(false)
	_show_idle()

func _process(_delta: float) -> void:
	_update_aim()

func _perform_attack(_dir: Vector2) -> void:
	if _is_attacking:
		return
	super._perform_attack(_dir)
	_hit_targets.clear()
	_is_attacking = true
	_set_hitbox_enabled(true)
	_show_swing()

func _show_idle() -> void:
	idle_sprite.visible = true
	swing_sprite.visible = false

func _show_swing() -> void:
	idle_sprite.visible = false
	swing_sprite.visible = true
	swing_sprite.play("swing")

func _on_swing_finished() -> void:
	_is_attacking = false
	_set_hitbox_enabled(false)
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
