extends EnemyBase
class_name WolfEnemy

var dash_damage: int = 2
var dash_speed: float = 400.0

func _ready() -> void:
	speed = 120.0
	contact_damage = 1
	max_hp = 3
	super._ready()
