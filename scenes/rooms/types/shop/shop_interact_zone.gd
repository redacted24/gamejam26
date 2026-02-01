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

func _ready() -> void:
	interact_text = get_node("InteractText")
	interact_text.hide()
	if cards_container_path:
		cards_container = get_node_or_null(cards_container_path)
	if cards_container:
		# Store target positions and move cards off-screen
		for card in cards_container.get_children():
			card_targets[card] = card.position
			card.position.y = 800

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and valid_interact and not cards_shown:
		cards_shown = true
		interact_text.hide()
		if cards_container:
			cards_container.visible = true
			_tween_cards_in()

	if cards_shown and cards_container:
		_check_card_hover()

func _check_card_hover() -> void:
	var mouse_pos := get_global_mouse_position()
	var new_hovered: Sprite2D = null

	for card in cards_container.get_children():
		if card is Sprite2D and card.texture:
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
	for card in cards_container.get_children():
		var target_pos: Vector2 = card_targets[card]
		var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(card, "position", target_pos, tween_duration).set_delay(delay)
		delay += 0.1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		valid_interact = true
		if not cards_shown:
			interact_text.show()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		valid_interact = false
		interact_text.hide()
