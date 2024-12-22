extends Control

# When the Tutorial button is pressed
func _on_tutorial_button_pressed() -> void:
	AXMenuManager.push_menu("tutorial")
