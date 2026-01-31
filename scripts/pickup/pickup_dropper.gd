extends RefCounted
class_name PickupDropper

const DROP_CHANCE := 0.3

const PICKUP_DEFS := [
	{
		type = "health",
		value = 1.0,
		weight = 3.0,
		color = Color(0.9, 0.2, 0.2),
		points = [
			Vector2(0, -4), Vector2(5, -9), Vector2(10, -4),
			Vector2(10, 2), Vector2(0, 10),
			Vector2(-10, 2), Vector2(-10, -4), Vector2(-5, -9),
		],
	},
	{
		type = "damage_up",
		value = 1.0,
		weight = 1.0,
		color = Color(0.9, 0.5, 0.1),
		points = [
			Vector2(0, -10), Vector2(6, -2),
			Vector2(3, -2), Vector2(3, 8),
			Vector2(-3, 8), Vector2(-3, -2), Vector2(-6, -2),
		],
	},
	{
		type = "speed_up",
		value = 30.0,
		weight = 1.0,
		color = Color(0.2, 0.8, 0.3),
		points = [
			Vector2(0, -10), Vector2(6, -2),
			Vector2(3, -2), Vector2(3, 8),
			Vector2(-3, 8), Vector2(-3, -2), Vector2(-6, -2),
		],
	},
]

static func try_drop(pos: Vector2, parent: Node) -> void:
	if randf() > DROP_CHANCE:
		return

	var def: Dictionary = _pick_weighted()
	var pickup := Pickup.new()
	pickup.setup(
		def.type,
		def.value,
		def.color,
		PackedVector2Array(def.points),
	)
	pickup.position = pos
	parent.call_deferred("add_child", pickup)

static func _pick_weighted() -> Dictionary:
	var total_weight := 0.0
	for d in PICKUP_DEFS:
		total_weight += d.weight

	var roll := randf() * total_weight
	var cumulative := 0.0
	for d in PICKUP_DEFS:
		cumulative += d.weight
		if roll <= cumulative:
			return d

	return PICKUP_DEFS[0]
