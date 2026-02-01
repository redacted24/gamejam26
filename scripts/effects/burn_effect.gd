extends Node
class_name BurnEffect

var burn_damage: int = 1
var tick_interval: float = 0.5
var total_duration: float = 2.0

var _tick_timer: float = 0.0
var _total_timer: float = 0.0
var _tinted_sprite: AnimatedSprite2D = null
var _original_modulate: Color = Color.WHITE

func setup(dmg: int = 1, interval: float = 0.5, duration: float = 2.0) -> void:
	burn_damage = dmg
	tick_interval = interval
	total_duration = duration

func _ready() -> void:
	_tinted_sprite = get_parent().get_node_or_null("AnimatedSprite2D")
	if _tinted_sprite:
		_original_modulate = _tinted_sprite.modulate
		_tinted_sprite.modulate = Color(1.0, 0.6, 0.2)

func _process(delta: float) -> void:
	_total_timer += delta
	_tick_timer += delta

	if _tick_timer >= tick_interval:
		_tick_timer -= tick_interval
		var parent := get_parent()
		if parent.has_method("take_damage"):
			parent.take_damage(burn_damage, Vector2.ZERO)

	if _total_timer >= total_duration:
		_remove()

func _remove() -> void:
	if _tinted_sprite and is_instance_valid(_tinted_sprite):
		_tinted_sprite.modulate = _original_modulate
	queue_free()
