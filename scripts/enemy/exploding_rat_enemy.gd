extends EnemyBase
class_name ExplodingRatEnemy

var explosion_damage: int = 2
var explosion_radius: float = 80.0

func _ready() -> void:
	speed = 90.0
	contact_damage = 0
	max_hp = 2
	super._ready()
