extends "res://screenreader/menu/base_menu.gd"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init()
	
func _on_button_pressed() -> void:
	AXMenuManager.pop_menu()
