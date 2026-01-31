extends EnemyBase
class_name BatEnemy

# Bat movement settings
var circle_radius: float = 80.0
var circle_speed: float = 2.5
var swoop_speed: float = 200.0
var swoop_cooldown: float = 3.0

func _ready() -> void:
	speed = 60.0
	contact_damage = 1
	max_hp = 2
	super._ready()
