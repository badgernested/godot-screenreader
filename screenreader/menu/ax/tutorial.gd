extends "res://screenreader/menu/base_menu.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fix_keys_rec($Panel/VBox/Content/Center/Panel/Contents/TutorialControl)
	init()
	AXController.enable_screenreader($Panel, true, $Panel/VBox/Content/Center/Panel/Contents/TutorialControl/Tab/Introduction/CenterContainer)

func fix_keys_rec(node: Control):
	for c in node.get_children():
		if c is Label:
			c.text = TextFunctions.replace_all_keyboard_strings(c.text)
			
		fix_keys_rec(c)
