extends EnemyBase
class_name SnakeEnemy

var spit_damage: int = 1
var spit_speed: float = 180.0
var spit_cooldown: float = 2.5
var spit_count: int = 3
var spit_spread: float = 0.4  # radians between each projectile

func _ready() -> void:
	speed = 70.0
	contact_damage = 1
	max_hp = 3
	super._ready()
