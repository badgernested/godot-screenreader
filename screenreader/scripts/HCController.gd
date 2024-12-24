###############################################
# HCController
#
# Controls high contrast mode.
###############################################
class_name HCController
extends Object

# These are the focus styles for the selected object
const FOCUS_STYLE = {
	"default" : preload("res://screenreader/ui/style/focus_end_node.tres"),
	"hc_dark" : preload("res://screenreader/ui/style/focus_end_node_hc_dark.tres"),
	"hc_light" : preload("res://screenreader/ui/style/focus_end_node_hc_dark.tres")
}

# This is the style 
const STYLES = {
	"hc_dark" : preload("res://screenreader/ui/style/HiContrast_Dark.tres"),
	"hc_light" : preload("res://screenreader/ui/style/HiContrast_Light.tres")
}

# This is the gradient for the top borders of accessibility menus
const GRADIENT_STYLES = {
	"hc_dark" : preload("res://screenreader/ui/gradient/DarkMode.tres"),
	"hc_light" : preload("res://screenreader/ui/gradient/LightMode.tres"),
	"default" : preload("res://screenreader/ui/gradient/AccessDefault.tres")
}


# This stores the theme data for every object within the root.
static var _theme_data: Dictionary = {}

# This is the style you are using.
static var theme_style: String = "none"

# Gets the focus style
static func get_focus_style():
	if FOCUS_STYLE.has(theme_style):
		return FOCUS_STYLE[theme_style]
		
	return FOCUS_STYLE["default"]
	
# Gets the style
static func get_style():
	if STYLES.has(theme_style):
		return STYLES[theme_style]
		
	return null
	
# Gets the gradient
static func get_gradient():
	if GRADIENT_STYLES.has(theme_style):
		return GRADIENT_STYLES[theme_style]
		
	return null

# Sets the theme to a new theme
static func set_theme(root: Control = Screenreader.dom_root, theme: String = theme_style):
	if root != null:
		reset_theme()
		_theme_data[root] = root.theme
		if !theme.is_empty():
			theme_style = theme
			
		if STYLES.has(theme_style):
			_set_theme_rec(root, get_style())
		else:
			reset_theme()
	
static func _set_theme_rec(root: Control, theme: Theme):
	for c in root.get_children():
		_theme_data[c] = c.theme
		root.theme = theme
		
		if c.get_child_count() > 0:
			_set_theme_rec(c,theme)
	
# Resets the theme to the original
static func reset_theme():
	_reset_theme_rec()
	theme_style = ""
	_theme_data = {}
	
static func _reset_theme_rec():
	for c in _theme_data:
		if is_instance_valid(c):
			c.theme = _theme_data[c]
