extends Node2D

@onready var interact_text: Label

@export var cards_container_path: NodePath
@export var tween_duration: float = 0.5

var cards_container: Node2D
var valid_interact: bool = false
var cards_shown: bool = false
var card_targets: Dictionary = {}

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
