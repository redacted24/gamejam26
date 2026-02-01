extends EnemyBase
class_name WolfEnemy

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var death_sound: AudioStreamPlayer = $DeathSound
@onready var attack_sound: AudioStreamPlayer = $AttackSound

var dash_damage: int = 3
var dash_speed: float = 550.0
var _hurt: bool = false

func _ready() -> void:
	speed = 130.0
	contact_damage = 2
	max_hp = 8
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	if not animated_sprite:
		return
	if velocity.length() > 5.0:
		if not animated_sprite.is_playing() or animated_sprite.animation != "walk_left":
			animated_sprite.play("walk_left")
	else:
		if animated_sprite.animation != "default":
			animated_sprite.play("default")
	if velocity.length() > 10.0:
		animated_sprite.flip_h = velocity.x > 0

func _on_died() -> void:
	velocity = Vector2.ZERO
	collision_shape.set_deferred("disabled", true)
	var sm := get_node_or_null("StateMachine")
	if sm:
		sm.process_mode = Node.PROCESS_MODE_DISABLED
	animated_sprite.stop()
	death_sound.play()
	EventBus.enemy_died.emit(global_position)
	if NetworkManager.is_online() and multiplayer.is_server():
		_remote_die.rpc()
	var tween := create_tween()
	tween.tween_property(animated_sprite, "modulate:a", 0.0, 0.7)
	tween.tween_callback(queue_free)

func take_damage(amount: int, from_position: Vector2 = Vector2.ZERO) -> void:
	_hurt = true
	super.take_damage(amount, from_position)
	if health_component.current_hp > 0:
		var tween := create_tween()
		tween.tween_callback(func(): _hurt = false).set_delay(0.75)
