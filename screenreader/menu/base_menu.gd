###############################################
# BaseMenu
#
# Represents the base menu, so it allows it to
# have a label and center space for content.
###############################################
extends Control

# Whether the control is centered on init
@export var centered: bool = false
@export var focus_node: NodePath = NodePath()

# Whether or not the mouse is on the titlebar
var mouse_titlebar:bool = false

# Position on the panel when clicked
var click_position:Vector2 = Vector2.ZERO

var focused_element = null

const BUTTON_STYLES = {
	"default" : preload("res://screenreader/ui/img/default/x_box.png"),
	"hc_dark" : preload("res://screenreader/ui/img/dark/x_box.png"),
	"hc_light" : preload("res://screenreader/ui/img/light/x_box.png")
}

## Functions 

func screenreader_focus():
	pass
	
# Closes the menu
func close():
	AXMenuManager._pop_menu()

func set_title_gradient():
	var gradient = HCController.get_gradient()
	if gradient == null:
		gradient = HCController._GRADIENT_STYLES["default"]
		
	$Panel/VBox/Title/HBoxContainer/ColorRect/Center/TitleGradient.texture = gradient

## Signals

# Runs when the control is added to the scene tree
func init() -> void:
	# Centers the window
	if centered:
		var window = get_window()

		$Panel.position = (window.size * 0.5) - ($Panel.size * 0.5)
	
	# Sets the title gradient
	set_title_gradient()
	
	# Sets the close button style
	var button_style = BUTTON_STYLES["default"]
	
	if BUTTON_STYLES.has(HCController.theme_style):
		button_style = BUTTON_STYLES[HCController.theme_style]
		
	$Panel/VBox/Title/HBoxContainer/ColorRect/Grid/EndButtons/HBox/Close.icon = button_style

func _process(_delta: float) -> void:
	if mouse_titlebar:
		$Panel.position = get_viewport().get_mouse_position() - click_position

# When the close button is pressed
func _on_close_pressed() -> void:
	close()

func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT :
				mouse_titlebar = true
				click_position = event.position
		elif event.is_released():
			mouse_titlebar = false


func _on_tree_entered() -> void:
	Screenreader._play_sound("menu_open")


func _on_tree_exited() -> void:
	Screenreader._play_sound("menu_close")
