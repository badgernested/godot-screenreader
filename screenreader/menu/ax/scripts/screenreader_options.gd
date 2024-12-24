extends "res://screenreader/menu/base_menu.gd"

func _ready() -> void:
	init()
	$Panel/VBox/Content/Center/Panel/Contents/OptionsControl.parent = self


func _on_ok_pressed() -> void:
	$Panel/VBox/Content/Center/Panel/Contents/OptionsControl.do_ok()
	AXMenuManager.pop_menu()


func _on_cancel_pressed() -> void:
	$Panel/VBox/Content/Center/Panel/Contents/OptionsControl.do_cancel()
	AXMenuManager.pop_menu()


func _on_close_2_pressed() -> void:
	_on_cancel_pressed()
