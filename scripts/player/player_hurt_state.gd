extends State

const HURT_DURATION := 0.8
const FLASH_SPEED := 15.0
const KNOCKBACK_SPEED := 400.0
const KNOCKBACK_DECEL := 600.0

var _timer: float = 0.0
var _knockback_velocity: Vector2 = Vector2.ZERO

func enter() -> void:
	var player: Player = get_parent().get_parent()
	player.invincible = true
	_timer = 0.0

	# Calculate knockback direction away from the hit source
	if player.last_hit_position != Vector2.ZERO:
		var knockback_dir := (player.global_position - player.last_hit_position).normalized()
		_knockback_velocity = knockback_dir * KNOCKBACK_SPEED
	else:
		_knockback_velocity = Vector2.ZERO

func exit() -> void:
	var player: Player = get_parent().get_parent()
	player.invincible = false
	var sprite: AnimatedSprite2D = player.get_node_or_null("AnimatedSprite2D")
	if sprite:
		sprite.modulate = CosmeticsData.selected_color if CosmeticsData else Color.WHITE

func process(delta: float) -> void:
	_timer += delta
	var player: Player = get_parent().get_parent()

	# Red flash: alternate between red tint and normal
	var sprite: AnimatedSprite2D = player.get_node_or_null("AnimatedSprite2D")
	if sprite:
		var flash: float = absf(sin(_timer * FLASH_SPEED))
		var base_color: Color = CosmeticsData.selected_color if CosmeticsData else Color.WHITE
		sprite.modulate = base_color.lerp(Color(1, 0.2, 0.2), flash * 0.7)
		sprite.modulate.a = 0.4 + 0.6 * flash

	if _timer >= HURT_DURATION:
		Transitioned.emit(self, "idle")

func physics_process(delta: float) -> void:
	var player: Player = get_parent().get_parent()
	if NetworkManager.is_online() and not player.is_multiplayer_authority():
		return

	# Decelerate knockback over time
	_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_DECEL * delta)

	# Combine knockback with reduced player input
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player.velocity = _knockback_velocity + dir * player.stats.speed * 0.5
	player.move_and_slide()
