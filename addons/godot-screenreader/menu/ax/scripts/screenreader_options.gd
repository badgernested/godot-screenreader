extends "res://addons/godot-screenreader/menu/base_menu.gd"

func _ready() -> void:
	init()
	$Panel/VBox/Content/Center/Panel/Contents/OptionsControl.parent = self

func init():
	super()
	
	# Sets the close button style
	var button_style = BUTTON_STYLES["default"]
	
	if BUTTON_STYLES.has(HCController.theme_style):
		button_style = BUTTON_STYLES[HCController.theme_style]
		
	$Panel/VBox/Title/HBoxContainer/ColorRect/Grid/EndButtons/HBox/Close2.icon = button_style

func _on_ok_pressed() -> void:
	$Panel/VBox/Content/Center/Panel/Contents/OptionsControl.do_ok()
	AXController._menu_manager._pop_menu()


func _on_cancel_pressed() -> void:
	$Panel/VBox/Content/Center/Panel/Contents/OptionsControl.do_cancel()
	AXController._menu_manager._pop_menu()


func _on_close_2_pressed() -> void:
	_on_cancel_pressed()
