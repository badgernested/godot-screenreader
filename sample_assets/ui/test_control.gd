extends "res://addons/godot-screenreader/scripts/object_scripts/ax_control.gd"

const BUTTON_ON = "Button turned on."
const BUTTON_OFF = "Button turned off."

# If true, just got interacted with.
var _pressed = false

## If this value returns a non-empty value, it will read that
## string instead of the default string for the screenreader
## when it reads its name.
func ax_custom_text() -> String:
	return "Custom control Demonstration."

## When this function returns true, it will override 
## the regular input function of the control.
## Note that this will require you to manually 
## insert all emit_signal calls.
func ax_function_override() -> bool:
	if Input.is_action_just_pressed("DOM_item_decrement"):
		$HBoxContainer/CheckButton.button_pressed = false
		AXController.add_token(BUTTON_OFF)
		AXController.read_tokens()
		_pressed = true
		
	elif Input.is_action_just_pressed("DOM_item_increment"):
		$HBoxContainer/CheckButton.button_pressed = true
		AXController.add_token(BUTTON_ON)
		AXController.read_tokens()
		_pressed = true
	
	return true
	
## If this method returns true, the default screenreader
## navigation functionality will still be called.
## Typically if you did some other functionality this frame,
## you don't want to trigger navigation too. So make this
## return false if you trigger functionality this frame.
func ax_screenreader_navigation() -> bool:
	if _pressed:
		_pressed = false
		return false
	
	return true
