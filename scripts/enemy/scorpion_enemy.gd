extends EnemyBase
class_name ScorpionEnemy

var stab_damage: int = 2

func _ready() -> void:
	speed = 60.0
	contact_damage = 1
	max_hp = 5
	super._ready()
