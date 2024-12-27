extends Control
## Script for adding additional accessibility function to Control Controls.
##
## This script is designed to extend functionality for the Control Control
## to godot-screenreader. Extend this script to add additional functionality
## such as custom screenreader text and input.

## If true, this Control will be used to mark a group with its children.
@export var focus_marked_container: bool = false
## Whether or not this Control is ignored during navigation generation.
@export var ignore: bool = false
## If true, this node is set to [param focus_mode] = [param FOCUS_MODE_CLICK]
## instead of [param FOCUS_MODE_NONE] when the screenreader has loaded this Control.
@export var enable_mouse: bool = false

## If this value returns a non-empty value, it will read that
## string instead of the default string for the screenreader
## when it reads its name.
func ax_custom_text() -> String:
	return ""

## When this function returns true, it will override 
## the regular input function of the control.
## Note that this will require you to manually 
## insert all emit_signal calls.
func ax_function_override() -> bool:
	return false
	
## If this method returns true, the default screenreader
## navigation functionality will still be called.
## Typically if you did some other functionality this frame,
## you don't want to trigger navigation too. So make this
## return false if you trigger functionality this frame.
func ax_screenreader_navigation() -> bool:
	return true
