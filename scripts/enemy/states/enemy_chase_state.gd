extends State
class_name EnemyChaseState

func physics_process(_delta: float) -> void:
	var enemy: EnemyBase = get_parent().get_parent()
	var player := enemy.get_player()
	if not player:
		return

	var dir := (player.global_position - enemy.global_position).normalized()
	enemy.velocity = dir * enemy.speed
	enemy.move_and_slide()
