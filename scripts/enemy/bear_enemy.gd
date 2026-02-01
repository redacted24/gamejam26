extends EnemyBase
class_name BearEnemy

const WORM_SCENE: PackedScene = preload("res://scenes/enemies/worm_enemy.tscn")

var max_worms: int = 5
var spawn_cooldown: float = 4.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	speed = 40.0
	contact_damage = 2
	max_hp = 8
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	if not animated_sprite:
		return
	if velocity.length() > 5.0:
		if not animated_sprite.is_playing() or animated_sprite.animation != "walk":
			animated_sprite.play("walk")
	else:
		if not animated_sprite.is_playing() or animated_sprite.animation != "default":
			animated_sprite.play("default")

func spawn_worm() -> void:
	var worm := WORM_SCENE.instantiate()
	# Spawn slightly behind the bear (away from player)
	var offset := Vector2(randf_range(-30, 30), randf_range(-30, 30))
	worm.global_position = global_position + offset
	get_tree().current_scene.call_deferred("add_child", worm)

func get_alive_worm_count() -> int:
	var count := 0
	for node in get_tree().get_nodes_in_group("enemies"):
		if node is WormEnemy:
			count += 1
	return count

func _on_died() -> void:
	_drop_meat()
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
	tween.tween_property(animated_sprite, "modulate:a", 0.0, 0.7)
	tween.tween_callback(queue_free)
