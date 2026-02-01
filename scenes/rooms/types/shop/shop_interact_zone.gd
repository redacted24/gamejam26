extends Node2D

@onready var interact_text: Label

@export var cards_container_path: NodePath
@export var tween_duration: float = 0.5
@export var hover_offset: float = 20.0

var cards_container: Node2D
var valid_interact: bool = false
var cards_shown: bool = false
var card_targets: Dictionary = {}
var hovered_card: Sprite2D = null
var purchased: bool = false

func _ready() -> void:
	interact_text = get_node("InteractText")
	interact_text.hide()
	if cards_container_path:
		cards_container = get_node_or_null(cards_container_path)
	if cards_container:
		# Store target positions and move cards off-screen (direct children only)
		for card in cards_container.get_children():
			if card is Sprite2D and card.get_parent() == cards_container:
				card_targets[card] = card.position
				card.position.y = 800

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and valid_interact and not cards_shown:
		cards_shown = true
		interact_text.hide()
		if cards_container:
			cards_container.visible = true
			_tween_cards_in()

	if cards_shown and cards_container and not purchased:
		_check_card_hover()
		if Input.is_action_just_pressed("shoot") and hovered_card:
			_purchase_card(hovered_card)

func _check_card_hover() -> void:
	var mouse_pos := get_global_mouse_position()
	var new_hovered: Sprite2D = null

	for card in card_targets.keys():
		if is_instance_valid(card):
			var card_rect := _get_card_rect(card)
			if card_rect.has_point(mouse_pos):
				new_hovered = card
				break

	if new_hovered != hovered_card:
		# Un-hover previous card
		if hovered_card:
			var target_pos: Vector2 = card_targets[hovered_card]
			var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			tween.tween_property(hovered_card, "position", target_pos, 0.15)

		# Hover new card
		if new_hovered:
			var target_pos: Vector2 = card_targets[new_hovered]
			var hover_pos := Vector2(target_pos.x, target_pos.y - hover_offset)
			var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			tween.tween_property(new_hovered, "position", hover_pos, 0.15)

		hovered_card = new_hovered

func _get_card_rect(card: Sprite2D) -> Rect2:
	var texture_size := card.texture.get_size() * card.scale
	var pos := card.global_position - texture_size / 2
	return Rect2(pos, texture_size)

func _tween_cards_in() -> void:
	var delay := 0.0
	for card in card_targets.keys():
		var target_pos: Vector2 = card_targets[card]
		var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(card, "position", target_pos, tween_duration).set_delay(delay)
		delay += 0.1

func _purchase_card(card: Sprite2D) -> void:
	var player := _get_player()
	if not player:
		return

	var index := card_targets.keys().find(card)
	match index:
		0:  # +5 HP
			player.health_component.max_hp += 5
			player.health_component.current_hp += 5
			player.health_component.health_changed.emit(player.health_component.current_hp, player.health_component.max_hp)
		1:  # +1 damage
			player.stats.damage += 1
			if player.current_weapon:
				player.current_weapon.damage = player.stats.damage
		2:  # +25% speed
			player.stats.speed *= 1.25

	purchased = true
	hovered_card = null

	# Animate all cards out
	for c in card_targets.keys():
		if not is_instance_valid(c):
			continue
		var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		if c == card:
			# Selected card flies up
			tween.tween_property(c, "position:y", -200.0, 0.3)
		else:
			# Other cards fade out
			tween.tween_property(c, "modulate:a", 0.0, 0.3)
		tween.tween_callback(c.queue_free)
	card_targets.clear()

func _get_player() -> Player:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0] as Player
	return null

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		valid_interact = true
		if not cards_shown:
			interact_text.show()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		valid_interact = false
		interact_text.hide()
