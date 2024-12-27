extends Control

# When the Tutorial button is pressed
func _on_tutorial_button_pressed() -> void:
	AXController._menu_manager._push_menu("tutorial")


func _on_node_select_button_pressed() -> void:
	AXController._menu_manager._push_menu("node_select")


func _on_options_pressed() -> void:
	AXController._menu_manager._push_menu("screenreader_options")
