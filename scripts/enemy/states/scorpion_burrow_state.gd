extends State

@export var enemy: CharacterBody2D

enum Phase { BURROWED, SURFACING, STABBING, BURROWING }

var phase: int = Phase.BURROWED
var timer: float = 0.0
var target_pos: Vector2 = Vector2.ZERO
var base_scale: Vector2 = Vector2(0.25, 0.25)

# Knockback
var knockback_velocity: Vector2 = Vector2.ZERO

const BURROW_DURATION := 1.5
const SURFACE_TIME := 0.2
const STAB_TIME := 0.3
const REBURROW_TIME := 0.15

func enter() -> void:
	phase = Phase.BURROWED
	timer = BURROW_DURATION
	knockback_velocity = Vector2.ZERO
	_go_invisible()

	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		base_scale = visual.scale

func physics_process(delta: float) -> void:
	if knockback_velocity.length() > 5:
		enemy.velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 6.0 * delta)
		enemy.move_and_slide()
		return

	timer -= delta

	match phase:
		Phase.BURROWED:
			_do_burrowed(delta)
		Phase.SURFACING:
			_do_surfacing(delta)
		Phase.STABBING:
			_do_stabbing(delta)
		Phase.BURROWING:
			_do_burrowing(delta)

func _do_burrowed(delta: float) -> void:
	# Move toward player while underground
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		enemy.velocity = Vector2.ZERO
		enemy.move_and_slide()
		return

	var to_player: Vector2 = (player.global_position - enemy.global_position).normalized()
	enemy.velocity = to_player * enemy.speed * 1.5
	enemy.move_and_slide()

	var dist: float = enemy.global_position.distance_to(player.global_position)
	if timer <= 0 or dist < 40:
		phase = Phase.SURFACING
		timer = SURFACE_TIME
		enemy.velocity = Vector2.ZERO
		_go_visible()

func _do_surfacing(delta: float) -> void:
	enemy.velocity = Vector2.ZERO
	if timer <= 0:
		phase = Phase.STABBING
		timer = STAB_TIME
		_do_stab_attack()

func _do_stabbing(delta: float) -> void:
	enemy.velocity = Vector2.ZERO
	if timer <= 0:
		phase = Phase.BURROWING
		timer = REBURROW_TIME

func _do_burrowing(delta: float) -> void:
	enemy.velocity = Vector2.ZERO
	if timer <= 0:
		phase = Phase.BURROWED
		timer = BURROW_DURATION + randf_range(-0.3, 0.5)
		_go_invisible()

func _do_stab_attack() -> void:
	var scorpion := enemy as ScorpionEnemy
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return

	var dist: float = enemy.global_position.distance_to(player.global_position)
	if dist < 50 and player.has_method("take_damage"):
		player.take_damage(scorpion.stab_damage, enemy.global_position)

	# Stab visual
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		var dir: Vector2 = (player.global_position - enemy.global_position).normalized()
		var tween := enemy.create_tween()
		tween.tween_property(visual, "position", dir * 10, 0.08)
		tween.tween_property(visual, "position", Vector2.ZERO, 0.12)

func _go_invisible() -> void:
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		var tween := enemy.create_tween()
		tween.tween_property(visual, "modulate:a", 0.15, 0.15)
	# Disable collision while burrowed
	var col := enemy.get_node_or_null("CollisionShape2D")
	if col:
		col.set_deferred("disabled", true)

func _go_visible() -> void:
	var visual := enemy.get_node_or_null("AnimatedSprite2D")
	if visual:
		var tween := enemy.create_tween()
		tween.tween_property(visual, "modulate:a", 1.0, 0.1)
		# Pop-up squash
		tween.parallel().tween_property(visual, "scale", base_scale * Vector2(0.8, 1.3), 0.1)
		tween.tween_property(visual, "scale", base_scale, 0.1)
	# Re-enable collision
	var col := enemy.get_node_or_null("CollisionShape2D")
	if col:
		col.set_deferred("disabled", false)

func apply_knockback(direction: Vector2, force: float) -> void:
	if phase == Phase.BURROWED:
		return  # Can't knockback while underground
	knockback_velocity = direction * force
	phase = Phase.BURROWING
	timer = 0.3
