extends EnemyBase
class_name OwlEnemy

var feather_damage: int = 1
var feather_speed: float = 200.0
var drop_cooldown: float = 1.2

func _ready() -> void:
	speed = 80.0
	contact_damage = 1
	max_hp = 3
	super._ready()
