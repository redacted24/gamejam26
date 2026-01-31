extends EnemyBase
class_name FireflyEnemy

var ring_damage: int = 1
var ring_speed: float = 120.0
var ring_cooldown: float = 3.5
var ring_count: int = 8

func _ready() -> void:
	speed = 70.0
	contact_damage = 1
	max_hp = 2
	super._ready()
