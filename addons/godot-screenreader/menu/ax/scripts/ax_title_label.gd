extends "res://addons/godot-screenreader/scripts/object_scripts/ax_label.gd"

const TITLE = "Window Title"

# If this value returns a non-empty value, it will read that
# string instead of the default string for the screenreader
# when it reads its name.
func ax_custom_text() -> String:
	return (text
			+ " | " 
			+ TITLE )
