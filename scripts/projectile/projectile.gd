extends Area2D
class_name Projectile

@export var speed: float = 300.0
@export var lifetime: float = 2.0
@export var is_player_projectile: bool = true

var direction: Vector2 = Vector2.ZERO
var damage: int = 1

var _timer: float = 0.0

func setup(dir: Vector2, dmg: int, spd: float = 300.0, player_proj: bool = true) -> void:
	direction = dir.normalized()
	damage = dmg
	speed = spd
	is_player_projectile = player_proj
	rotation = direction.angle()

func _ready() -> void:
	monitoring = true
	monitorable = false

	if is_player_projectile:
		collision_layer = 8
		collision_mask = 1 | 4 | 256  # walls + enemies + flying enemies
	else:
		collision_layer = 16
		collision_mask = 1 | 2  # walls + player

	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_timer += delta
	if _timer >= lifetime:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is StaticBody2D:
		queue_free()
		return
	if body.has_method("take_damage"):
		body.take_damage(damage, global_position)
	queue_free()
