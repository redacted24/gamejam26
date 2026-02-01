extends CanvasLayer

@export var dialogue_resource: DialogueResource
@export var start_from_title: String = ""
@export var auto_start: bool = false
@export var next_action: StringName = &"ui_accept"
@export var skip_action: StringName = &"ui_cancel"

var temporary_game_states: Array = []
var is_waiting_for_input: bool = false
var locals: Dictionary = {}

var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
		else:
			if owner == null:
				queue_free()
			else:
				hide()
	get:
		return dialogue_line

@onready var balloon: Control = %Balloon
@onready var dialogue_label: DialogueLabel = %DialogueLabel


func _ready() -> void:
	balloon.hide()
	if auto_start:
		start()


func _unhandled_input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()


func start(with_dialogue_resource: DialogueResource = null, title: String = "", extra_game_states: Array = []) -> void:
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	if is_instance_valid(with_dialogue_resource):
		dialogue_resource = with_dialogue_resource
	if not title.is_empty():
		start_from_title = title
	dialogue_line = await dialogue_resource.get_next_dialogue_line(start_from_title, temporary_game_states)
	show()


func apply_dialogue_line() -> void:
	is_waiting_for_input = false
	balloon.show()
	balloon.focus_mode = Control.FOCUS_ALL
	balloon.grab_focus()

	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line
	dialogue_label.show()

	if not dialogue_line.text.is_empty():
		dialogue_label.type_out()
		await dialogue_label.finished_typing

	is_waiting_for_input = true
	balloon.focus_mode = Control.FOCUS_ALL
	balloon.grab_focus()


func next(next_id: String) -> void:
	dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id, temporary_game_states)


func _on_balloon_gui_input(event: InputEvent) -> void:
	if dialogue_label.is_typing:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return

	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		next(dialogue_line.next_id)
	elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)
