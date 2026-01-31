extends Node

var selected_color_name: String = "Default"
var selected_color: Color = Color.WHITE

var color_options := {
	"Default": Color.WHITE,
	"Crimson": Color(1.0, 0.55, 0.55),
	"Ocean": Color(0.55, 0.7, 1.0),
	"Forest": Color(0.55, 1.0, 0.6),
	"Golden": Color(1.0, 0.85, 0.4),
	"Shadow": Color(0.65, 0.5, 0.8),
	"Frost": Color(0.7, 0.95, 1.0),
	"Ember": Color(1.0, 0.65, 0.3),
}

func select_color(color_name: String) -> void:
	if color_options.has(color_name):
		selected_color_name = color_name
		selected_color = color_options[color_name]
