extends Control

@onready var join_panel: VBoxContainer = $JoinPanel
@onready var ip_input: LineEdit = $JoinPanel/IpInput
@onready var status_label: Label = $StatusLabel
@onready var start_button: Button = $StartButton
@onready var host_button: Button = $HostButton
@onready var join_button: Button = $JoinButton

func _ready() -> void:
	NetworkManager.player_connected.connect(_on_player_connected)
	NetworkManager.player_disconnected.connect(_on_player_disconnected)
	NetworkManager.connection_succeeded.connect(_on_connection_succeeded)
	NetworkManager.connection_failed.connect(_on_connection_failed)
	NetworkManager.server_started.connect(_on_server_started)

func _on_play_button_pressed() -> void:
	NetworkManager.close_connection()
	EventBus.game_started.emit()
	get_tree().change_scene_to_file("res://scenes/rooms/types/cutscene_1.tscn")

func _on_host_button_pressed() -> void:
	var err := NetworkManager.host_game()
	if err != OK:
		status_label.text = "Failed to host (port in use?)"
		return
	host_button.disabled = true
	join_button.disabled = true
	join_panel.visible = false
	status_label.text = "Hosting... Waiting for player to join."

func _on_join_button_pressed() -> void:
	join_panel.visible = !join_panel.visible

func _on_connect_button_pressed() -> void:
	var ip := ip_input.text.strip_edges()
	if ip.is_empty():
		status_label.text = "Enter an IP address."
		return
	var err := NetworkManager.join_game(ip)
	if err != OK:
		status_label.text = "Failed to connect."
		return
	host_button.disabled = true
	join_button.disabled = true
	status_label.text = "Connecting to %s..." % ip

func _on_start_button_pressed() -> void:
	_start_game.rpc()

@rpc("authority", "call_local", "reliable")
func _start_game() -> void:
	EventBus.game_started.emit()
	get_tree().change_scene_to_file("res://scenes/rooms/types/room_crossroads.tscn")

func _on_server_started() -> void:
	status_label.text = "Hosting... Waiting for player to join."

func _on_player_connected(_peer_id: int) -> void:
	status_label.text = "Player connected! Ready to start."
	if NetworkManager.is_host:
		start_button.visible = true

func _on_player_disconnected(_peer_id: int) -> void:
	status_label.text = "Player disconnected."
	start_button.visible = false

func _on_connection_succeeded() -> void:
	status_label.text = "Connected! Waiting for host to start..."

func _on_connection_failed() -> void:
	status_label.text = "Connection failed."
	host_button.disabled = false
	join_button.disabled = false

func _on_cosmetics_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/cosmetics_menu.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")
