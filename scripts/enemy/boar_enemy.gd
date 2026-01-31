extends EnemyBase
class_name BoarEnemy

var charge_speed: float = 350.0
var charge_damage: int = 2

func _ready() -> void:
	speed = 50.0
	contact_damage = 1
	max_hp = 6
	super._ready()
