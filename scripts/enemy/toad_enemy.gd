extends EnemyBase
class_name ToadEnemy

var shoot_cooldown: float = 2.0
var projectile_speed: float = 150.0
var projectile_damage: int = 1

func _ready() -> void:
	speed = 100.0
	contact_damage = 1
	max_hp = 4
	super._ready()
