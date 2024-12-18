# This node keeps tracks of all keys pressed in any given frame
# credit to mrcdk on Godot forums.
extends Node

var pressed_keys = []
var last_pressed_keys = []


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.echo:
			# If the event is an echo event, skip it
			return
		if event.pressed:
			pressed_keys.push_back(event.keycode)
		else:
			while pressed_keys.has(event.keycode):
				pressed_keys.erase(event.keycode)

func _process(delta: float) -> void:
	last_pressed_keys = pressed_keys.duplicate()

func key_pressed():
	if key_changed():
		return last_pressed_keys.size() < pressed_keys.size()
	
func key_changed():
	if last_pressed_keys.size() != pressed_keys.size():
		return true
		
	for c in range(0, pressed_keys.size()):
		if pressed_keys[c] != last_pressed_keys[c]:
			return true
	
	return false
