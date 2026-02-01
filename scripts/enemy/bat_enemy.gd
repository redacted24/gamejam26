extends EnemyBase
class_name BatEnemy

# Bat movement settings
var circle_radius: float = 80.0
var circle_speed: float = 2.5
var swoop_speed: float = 200.0
var swoop_cooldown: float = 3.0

@onready var death_sound: AudioStreamPlayer = $DeathSound
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	speed = 60.0
	contact_damage = 1
	max_hp = 2
	super._ready()

func _on_died() -> void:
	_drop_meat()
	velocity = Vector2.ZERO
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
