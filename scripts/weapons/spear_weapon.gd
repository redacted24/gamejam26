extends WeaponBase
class_name SpearWeapon

@export var spear_attack_scene: PackedScene
@export var spear_range: float = 80.0
@export var spear_width: float = 20.0

func _perform_attack(dir: Vector2) -> void:
	super._perform_attack(dir)

	var spear: SpearAttack
	if spear_attack_scene:
		spear = spear_attack_scene.instantiate()
	else:
		spear = SpearAttack.new()

	spear.setup(dir, damage, spear_range, spear_width)
	spear.global_position = player.global_position
	player.get_tree().current_scene.add_child(spear)
