extends WeaponBase
class_name BowWeapon

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 300.0
@export var max_charge_time: float = 2.0
@export var min_damage_multiplier: float = 0.5
@export var max_damage_multiplier: float = 2.0
@export var min_speed_multiplier: float = 0.5
@export var max_speed_multiplier: float = 1.5

var is_charging: bool = false
var charge_time: float = 0.0

func _process(delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		if not is_charging:
			is_charging = true
			charge_time = 0.0
		else:
			charge_time = minf(charge_time + delta, max_charge_time)
	elif is_charging:
		# Released - fire the arrow
		_fire_charged_arrow()
		is_charging = false
		charge_time = 0.0

func _fire_charged_arrow() -> void:
	var charge_ratio := charge_time / max_charge_time
	var dir := _get_attack_direction()

	var proj: Projectile
	if projectile_scene:
		proj = projectile_scene.instantiate()
	else:
		proj = Projectile.new()

	var final_damage := int(damage * lerpf(min_damage_multiplier, max_damage_multiplier, charge_ratio))
	var final_speed := projectile_speed * lerpf(min_speed_multiplier, max_speed_multiplier, charge_ratio)

	proj.setup(dir, final_damage, final_speed, true)
	proj.global_position = player.global_position + dir * 20.0
	player.get_tree().current_scene.add_child(proj)

# Override to disable the base attack system
func try_attack() -> void:
	pass
