extends Area2D
class_name SpearAttack

@export var duration: float = 0.15

var direction: Vector2 = Vector2.RIGHT
var damage: int = 1
var attack_range: float = 80.0
var attack_width: float = 20.0

var _hit_targets: Array[Node2D] = []

func setup(dir: Vector2, dmg: int, rng: float = 80.0, width: float = 20.0) -> void:
	direction = dir.normalized()
	damage = dmg
	attack_range = rng
	attack_width = width

func _ready() -> void:
	monitoring = true
	monitorable = false
	collision_layer = 8  # player_projectiles layer
	collision_mask = 4 | 256  # enemies + flying enemies

	# Get or create collision shape
	var col := get_node_or_null("CollisionShape2D")
	if not col:
		col = CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(attack_range, attack_width)
		col.shape = rect
		add_child(col)
	elif col.shape is RectangleShape2D:
		col.shape.size = Vector2(attack_range, attack_width)

	col.position = direction * (attack_range / 2.0)
	col.rotation = direction.angle()

	# Get or create visual
	var visual := get_node_or_null("Sprite2D")
	if not visual:
		visual = ColorRect.new()
		visual.size = Vector2(attack_range, attack_width)
		visual.position = -Vector2(0, attack_width / 2.0)
		visual.color = Color(1.0, 1.0, 1.0, 0.6)
		add_child(visual)
	visual.rotation = direction.angle()

	body_entered.connect(_on_body_entered)

	# Auto-remove after duration
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duration)
	tween.tween_callback(queue_free)

func _on_body_entered(body: Node2D) -> void:
	if body in _hit_targets:
		return
	_hit_targets.append(body)

	if body.has_method("take_damage"):
		# Only host processes damage to enemies
		if body.is_in_group("enemies"):
			if NetworkManager.is_online() and not multiplayer.is_server():
				return
		body.take_damage(damage, global_position)
