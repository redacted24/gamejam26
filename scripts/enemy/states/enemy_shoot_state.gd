extends State
class_name EnemyShootState

@export var shoot_cooldown: float = 1.5
@export var projectile_speed: float = 200.0
@export var projectile_damage: int = 1

var _timer: float = 0.0

func enter() -> void:
	_timer = 0.0
	_fire()

func process(delta: float) -> void:
	_timer += delta
	if _timer >= shoot_cooldown:
		_timer = 0.0
		_fire()

func _fire() -> void:
	var enemy: EnemyBase = get_parent().get_parent()
	var player := enemy.get_player()
	if not player:
		return

	var dir := (player.global_position - enemy.global_position).normalized()
	var proj := Projectile.new()
	proj.setup(dir, projectile_damage, projectile_speed, false)
	proj.global_position = enemy.global_position + dir * 20.0
	enemy.get_tree().current_scene.add_child(proj)
