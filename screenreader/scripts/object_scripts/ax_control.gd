extends Control

@export var focus_marked_container: bool = false
@export var alt_text: String = ""
@export var ignore: bool = false

# If this value returns a non-empty value, it will read that
# string instead of the default string for the screenreader
# when it reads its name.
func ax_custom_text() -> String:
	return ""

# When this function returns true, it will override 
# the regular input function of the control.
# Note that this will require you to manually 
# insert all emit_signal calls.
func ax_function_override():
	return false
	
# If this method returns true, the default screenreader
# navigation functionality will still be called.
# Typically if you did some other functionality this frame,
# you don't want to trigger navigation too. So make this
# return false if you trigger functionality this frame.
func ax_screenreader_navigation():
	return true
