extends Area2D
class_name Projectile

var speed: float = 300.0
var direction: Vector2 = Vector2.ZERO
var damage: int = 1
var lifetime: float = 2.0
var is_player_projectile: bool = true

var _timer: float = 0.0

func _ready() -> void:
	monitoring = true
	monitorable = false

	if is_player_projectile:
		collision_layer = 8
		collision_mask = 1 | 4  # walls + enemies
	else:
		collision_layer = 16
		collision_mask = 1 | 2  # walls + player

	var col := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 5.0
	col.shape = circle
	add_child(col)

	var visual := ColorRect.new()
	visual.size = Vector2(8, 8)
	visual.position = Vector2(-4, -4)
	visual.color = Color.CORNFLOWER_BLUE if is_player_projectile else Color.INDIAN_RED
	add_child(visual)

	body_entered.connect(_on_body_entered)

func setup(dir: Vector2, dmg: int, spd: float = 300.0, player_proj: bool = true) -> void:
	direction = dir.normalized()
	damage = dmg
	speed = spd
	is_player_projectile = player_proj

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
