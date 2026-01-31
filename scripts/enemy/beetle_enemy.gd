extends EnemyBase
class_name BeetleEnemy

func _ready() -> void:
	speed = 110.0
	contact_damage = 1
	max_hp = 1
	super._ready()
