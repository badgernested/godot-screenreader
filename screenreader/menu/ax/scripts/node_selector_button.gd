extends "res://screenreader/scripts/object_scripts/ax_button.gd"

# Index of the position
var index: int = 0

var objects:Array = []

const SELECTED = "%s Selected"
const SELECT_ENTER = "Entered select mode."
const SELECT_EXIT = "Exited select mode."

# If this value returns a non-empty value, it will read that
# string instead of the default string for the screenreader
# when it reads its name.
func ax_custom_text() -> String:
	Screenreader.get_accessible_name(objects[index])
	return Screenreader._get_tokens()

# When this function returns true, it will override 
# the regular input function of the control.
# Note that this will require you to manually 
# insert all emit_signal calls.
func ax_function_override():
	if Input.is_action_just_pressed("DOM_item_decrement"):
		index -= 1
		
		if index < 0:
			index = 0
		
		update_parent_tab(objects[index])
		redraw_highlighter()
		read_access_text()
		Screenreader._play_sound("node_select", 1.2)
		return true
		
	elif Input.is_action_just_pressed("DOM_item_increment"):
		index += 1
		
		if index >= objects.size():
			index = objects.size()-1
			
		update_parent_tab(objects[index])
		
		redraw_highlighter()
		read_access_text()
		Screenreader._play_sound("node_select")
		return true
		
	elif Input.is_action_just_pressed("DOM_select"):
		AXController.add_token(SELECTED % [objects[index].get_class()])
		AXMenuManager._focused_node = objects[index]
		AXMenuManager.pop_all()
		return true
		
	return false
	
# If this method returns true, the default screenreader
# navigation functionality will still be called.
# Typically if you did some other functionality this frame,
# you don't want to trigger navigation too. So make this
# return false if you trigger functionality this frame.
func ax_screenreader_navigation():
	return true

func redraw_highlighter():
	await get_tree().create_timer(0.001).timeout
	Screenreader._update_draw_highlight(objects[index])
	AXController.queue_redraw()

func read_access_text():
	Screenreader.get_accessible_name(objects[index])
	Screenreader._tts_speak()
	
func update_parent_tab(obj):
	var tab_parent = get_tab_parent(obj)
	
	if tab_parent is TabContainer:
		var tab_bar = tab_parent.get_child(0, true)
		
		var children = tab_parent.get_children()
		
		for c in range(0, tab_parent.get_child_count()):
			if children[c].is_ancestor_of(obj):
				tab_bar.current_tab = c
				break
	
func get_tab_parent(obj):
	var returner = null
	var parent = obj.get_parent()
	
	if parent != null:
		if parent is TabContainer:
			return parent
		else:
			return get_tab_parent(parent)
	
	return returner

func _on_focus_entered() -> void:
	AXController.add_token(SELECT_ENTER)
	for c in AXMenuManager._menu_stack:
		c.modulate = Color(0.0, 0.0, 0.0, 0.0)
	Screenreader.clear_redraw = true
	update_parent_tab(objects[index])
	redraw_highlighter()
	Screenreader._play_sound("node_select")

func _on_focus_exited() -> void:
	AXController.add_token(SELECT_EXIT)
	for c in AXMenuManager._menu_stack:
		c.modulate = Color(1.0, 1.0, 1.0, 1.0)
	Screenreader._play_sound("node_select_exit")
