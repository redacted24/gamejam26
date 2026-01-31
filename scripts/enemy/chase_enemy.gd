extends EnemyBase
class_name ChaseEnemy

func _ready() -> void:
	speed = 80.0
	contact_damage = 1
	max_hp = 3
	super._ready()
