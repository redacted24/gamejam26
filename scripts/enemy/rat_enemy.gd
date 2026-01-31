extends EnemyBase
class_name RatEnemy

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	speed = 80.0
	contact_damage = 1
	max_hp = 3
	super._ready()

var sprite_angle_offset: float = PI
var _hurt: bool = false

func _process(_delta: float) -> void:
	if not animated_sprite:
		return
	if velocity.length() > 5.0:
		if not animated_sprite.is_playing() or animated_sprite.animation != "walk_side":
			animated_sprite.play("walk_side")
	# Sync collision capsule rotation with sprite (+ PI/2 because capsule is vertical by default)
	collision_shape.rotation = animated_sprite.rotation + PI / 2
	var rot := wrapf(animated_sprite.rotation, -PI, PI)
	var upside_down: bool = abs(rot) > PI / 2
	if _hurt:
		animated_sprite.flip_v = not upside_down
	else:
		animated_sprite.flip_v = upside_down

func take_damage(amount: int, from_position: Vector2 = Vector2.ZERO) -> void:
	_hurt = true
	super.take_damage(amount, from_position)
	if health_component.current_hp > 0:
		var tween := create_tween()
		tween.tween_callback(func(): _hurt = false).set_delay(0.75)
