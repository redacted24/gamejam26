extends Control

@onready var color_grid: GridContainer = $ColorGrid
@onready var preview_sprite: TextureRect = $Preview
@onready var selected_label: Label = $SelectedLabel

func _ready() -> void:
	_build_color_buttons()
	_apply_preview(CosmeticsData.selected_color_name)

func _build_color_buttons() -> void:
	for color_name in CosmeticsData.color_options:
		var color: Color = CosmeticsData.color_options[color_name]
		var btn := Button.new()
		btn.text = color_name
		btn.custom_minimum_size = Vector2(120, 50)
		btn.pressed.connect(_on_color_selected.bind(color_name))

		# Add a colored icon via a StyleBoxFlat override for visual indication
		var style := StyleBoxFlat.new()
		style.bg_color = color
		style.border_width_bottom = 2
		style.border_width_top = 2
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_color = Color(0.3, 0.3, 0.3)
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = 4
		style.corner_radius_bottom_right = 4

		var hover_style := StyleBoxFlat.new()
		hover_style.bg_color = color.lightened(0.2)
		hover_style.border_width_bottom = 2
		hover_style.border_width_top = 2
		hover_style.border_width_left = 2
		hover_style.border_width_right = 2
		hover_style.border_color = Color.WHITE
		hover_style.corner_radius_top_left = 4
		hover_style.corner_radius_top_right = 4
		hover_style.corner_radius_bottom_left = 4
		hover_style.corner_radius_bottom_right = 4

		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", hover_style)
		btn.add_theme_stylebox_override("pressed", hover_style)
		color_grid.add_child(btn)

func _on_color_selected(color_name: String) -> void:
	CosmeticsData.select_color(color_name)
	_apply_preview(color_name)

func _apply_preview(color_name: String) -> void:
	var color: Color = CosmeticsData.color_options[color_name]
	preview_sprite.modulate = color
	selected_label.text = "Selected: %s" % color_name

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
