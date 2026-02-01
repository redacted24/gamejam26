extends EnemyBase
class_name WormEnemy

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	speed = 90.0
	contact_damage = 1
	max_hp = 1
	drop_enabled = false
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	if not animated_sprite:
		return
	if velocity.length() > 5.0:
		if not animated_sprite.is_playing() or animated_sprite.animation != "walk":
			animated_sprite.play("walk")

func _on_died() -> void:
	velocity = Vector2.ZERO
	collision_shape.set_deferred("disabled", true)
	var sm := get_node_or_null("StateMachine")
	if sm:
		sm.process_mode = Node.PROCESS_MODE_DISABLED
	animated_sprite.stop()
	EventBus.enemy_died.emit(global_position)
	if NetworkManager.is_online() and multiplayer.is_server():
		_remote_die.rpc()
	var tween := create_tween()
	tween.tween_property(animated_sprite, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)
