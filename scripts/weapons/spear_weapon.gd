extends WeaponBase
class_name SpearWeapon

@export var spear_attack_scene: PackedScene
@export var spear_range: float = 80.0
@export var spear_width: float = 20.0

func _perform_attack(dir: Vector2) -> void:
	super._perform_attack(dir)

	var pos := player.global_position
	_spawn_spear(dir, damage, pos)
	_spawn_spear_remote.rpc(dir, damage, pos)

func _spawn_spear(dir: Vector2, dmg: int, pos: Vector2) -> void:
	var spear: SpearAttack
	if spear_attack_scene:
		spear = spear_attack_scene.instantiate()
	else:
		spear = SpearAttack.new()

	spear.setup(dir, dmg, spear_range, spear_width)
	spear.global_position = pos
	player.get_tree().current_scene.add_child(spear)

@rpc("any_peer", "call_remote", "reliable")
func _spawn_spear_remote(dir: Vector2, dmg: int, pos: Vector2) -> void:
	_spawn_spear(dir, dmg, pos)
