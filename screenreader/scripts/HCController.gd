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

# Saves the current theme data for the control
static func save_theme(root: Node=null):
	if root == null:
		root = AXController.get_tree().get_root()
	
	if root is Control:
		if !_theme_data.has(root):
			_theme_data[root] = root.theme
		
	for c in root.get_children():
		save_theme(c)

# Sets the theme to a new theme
static func set_theme(root: Node=null, theme: String = theme_style):
	if root == null:
		root = AXController.get_tree().get_root()

	save_theme(root)

	if STYLES.has(theme):
		theme_style = theme
		_set_theme_rec(root, get_style())
	else:
		reset_theme()
	
static func _set_theme_rec(root: Node, theme: Theme):
	if root is Control:
		root.theme = theme
	
	for c in root.get_children():
		if c.get_child_count() > 0:
			_set_theme_rec(c,theme)
	
# Resets the theme to the original
static func reset_theme():
	_reset_theme_rec()
	theme_style = ""
	_theme_data = {}
	
# Clears invalid themes
static func clean_theme():
	var remove = []
	
	for c in _theme_data:
		if !is_instance_valid(c) || c.is_queued_for_deletion():
			remove.append(c)
			
	for c in remove:
		_theme_data.erase(c)
	
static func _reset_theme_rec():
	for c in _theme_data:
		if is_instance_valid(c):
			c.theme = _theme_data[c]
