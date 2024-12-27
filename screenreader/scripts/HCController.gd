class_name HCController
extends Object
## This class controls high contrast mode.
##
## This class controls high contrast mode. Typically, you should control
## high contrast themes through [AXController] instead.

# These are the focus styles for the selected object
const _FOCUS_STYLE = {
	"default" : preload("res://screenreader/ui/style/focus_end_node.tres"),
	"hc_dark" : preload("res://screenreader/ui/style/focus_end_node_hc_dark.tres"),
	"hc_light" : preload("res://screenreader/ui/style/focus_end_node_hc_dark.tres")
}

# This is the style 
const _STYLES = {
	"hc_dark" : preload("res://screenreader/ui/style/HiContrast_Dark.tres"),
	"hc_light" : preload("res://screenreader/ui/style/HiContrast_Light.tres")
}

# This is the gradient for the top borders of accessibility menus
const _GRADIENT_STYLES = {
	"hc_dark" : preload("res://screenreader/ui/gradient/DarkMode.tres"),
	"hc_light" : preload("res://screenreader/ui/gradient/LightMode.tres"),
	"default" : preload("res://screenreader/ui/gradient/AccessDefault.tres")
}


# This stores the theme data for every object within the root.
static var _theme_data: Dictionary = {}

## The name of the current high contrast theme active.
static var theme_style: String = "none"

## Gets the current StyleBox of the focus selector.
static func get_focus_style() -> StyleBox:
	if _FOCUS_STYLE.has(theme_style):
		return _FOCUS_STYLE[theme_style]
		
	return _FOCUS_STYLE["default"]
	
## Gets the currently selected high contrast theme.
static func get_style() -> Theme:
	if _STYLES.has(theme_style):
		return _STYLES[theme_style]
		
	return null
	
## Gets the gradient for the currently selected high contrast theme.
static func get_gradient() -> Texture2D:
	if _GRADIENT_STYLES.has(theme_style):
		return _GRADIENT_STYLES[theme_style]
		
	return null

# Stores theme data
static func _save_theme(root: Node=null):
	if root == null:
		root = AXController.get_tree().get_root()
	
	if root is Control:
		if !_theme_data.has(root):
			_theme_data[root] = root.theme
		
	for c in root.get_children():
		_save_theme(c)

## Sets the theme to a new theme based on the theme style name.
static func set_theme(root: Node=null, theme: String = theme_style):
	_clean_theme()
	
	if root == null:
		root = AXController.get_tree().get_root()

	_save_theme(root)

	if _STYLES.has(theme):
		theme_style = theme
		_set_theme_rec(root, get_style())
	else:
		reset_theme()
	
# recursively sets the theme 
static func _set_theme_rec(root: Node, theme: Theme):
	if root is Control:
		root.theme = theme
	
	for c in root.get_children():
		if c.get_child_count() > 0:
			_set_theme_rec(c,theme)
	
## Resets the high contrast theme.
static func reset_theme():
	_reset_theme_rec()
	theme_style = ""
	_theme_data = {}
	
static func _reset_theme_rec():
	for c in _theme_data:
		if is_instance_valid(c):
			c.theme = _theme_data[c]

# Clears invalid themes
static func _clean_theme():
	var remove = []
	
	for c in _theme_data:
		if !is_instance_valid(c) || c.is_queued_for_deletion():
			remove.append(c)
			
	for c in remove:
		_theme_data.erase(c)
