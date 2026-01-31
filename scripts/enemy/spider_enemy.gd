extends EnemyBase
class_name SpiderEnemy

var web_damage: int = 0
var web_speed: float = 160.0
var web_cooldown: float = 3.0
var web_slow_duration: float = 3.0
var web_slow_radius: float = 40.0

func _ready() -> void:
	speed = 55.0
	contact_damage = 1
	max_hp = 4
	super._ready()
