extends EnemyBase
class_name WandererEnemy

func _ready() -> void:
	speed = 60.0
	contact_damage = 1
	_max_hp = 2
	super._ready()
