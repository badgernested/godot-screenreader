extends "res://addons/godot-screenreader/scripts/object_scripts/ax_button.gd"

# Index of the position
var index: int = 0

var objects:Array = []

const SELECTED = "%s Selected"

# Note, these correlate to the textbox names.
# For translating, only change the right side.
const TYPES = {
	"Labels": "Labels",
	"Buttons" : "Buttons",
	"Textboxes" : "Textboxes",
	"Sliders" : "Sliders",
	"Media" : "Media",
	"Other" : "Other"
}

@onready var parent = get_parent().get_parent().get_parent()

# If this value returns a non-empty value, it will read that
# string instead of the default string for the screenreader
# when it reads its name.
func ax_custom_text() -> String:
	#Screenreader._get_accessible_name(objects[index])
	return get_access_text()

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

	elif Input.is_action_just_pressed("DOM_item_increment"):
		index += 1
		
		if index >= objects.size():
			index = objects.size()-1
			
		update_parent_tab(objects[index])
		
		redraw_highlighter()
		read_access_text()
		Screenreader._play_sound("node_select")
		
	elif Input.is_action_just_pressed("DOM_prev"):
		var tab = get_parent().get_parent()
		var next_tab = tab.current_tab - 1
		
		if next_tab < 0:
			next_tab = 0
		
		var new_obj = tab.get_child(next_tab).get_child(0)
		
		if new_obj != Screenreader.focused:
			Screenreader._update_end_node(new_obj)
			Screenreader._play_sound("tab_nav")
		
	elif Input.is_action_just_pressed("DOM_next"):
		var tab = get_parent().get_parent()
		var next_tab = tab.current_tab + 1
		
		if next_tab >= tab.get_tab_count():
			next_tab = tab.get_tab_count()-1
		
		var new_obj = tab.get_child(next_tab).get_child(0)
		
		if new_obj != Screenreader.focused:
			Screenreader._update_end_node(new_obj)
			Screenreader._play_sound("tab_nav")

	elif Input.is_action_just_pressed("DOM_select"):
		AXController.add_token(SELECTED % [objects[index].get_class()])
		AXController._menu_manager._focused_node = objects[index]
		AXController._menu_manager._pop_all()

	elif Input.is_action_just_pressed("DOM_down"):
		AXController.add_token(parent.SELECT_EXIT)
		parent.select_mode = false
		# Moves to title
		Screenreader._update_end_node_position(0, 0)

	elif Input.is_action_just_pressed("DOM_up"):
		AXController.add_token(parent.SELECT_EXIT)
		parent.select_mode = false
		# Moves to tabs
		Screenreader._update_end_node_position(0, 2)

	return true
	
# If this method returns true, the default screenreader
# navigation functionality will still be called.
# Typically if you did some other functionality this frame,
# you don't want to trigger navigation too. So make this
# return false if you trigger functionality this frame.
func ax_screenreader_navigation():
	return false

func redraw_highlighter():
	if Screenreader.focused == self:
		await get_tree().create_timer(0.001).timeout
		Screenreader._update_draw_highlight(objects[index])
		AXController.queue_redraw()

func read_access_text():
	Screenreader._tts_speak_direct(get_access_text())
	
# To do - build custom reader information
	
const _SPECIAL_CONTROL_NAMES = {
	"IMAGE" : "Image",
	"PROGRESS_BAR" : "Progress Bar",
	"HSLIDER" : "Horizontal Slider",
	"VSLIDER" : "Vertical Slider",
	"SPINBOX" : "Spinbox",
	"LABEL" : "Label",
	"BUTTON" : "Button",
	"MENUBAR" : "Menu Bar",
	"TABS" : "Tabs",
	"CHECKBOX" : "Check Box",
	"SWITCH" : "Switch",
	"MENUBUTTON" : "Menu Button",
	"DROPDOWN" : "Dropdown"
}
	
func get_access_text():
	var obj = objects[index]
	
	var returner = ""
	
	if obj is TextureRect:
		if obj.get("alt_text") != null && !obj.alt_text.strip_edges().is_empty():
			return "%s | %s" % [Screenreader._SPECIAL_CONTROL_NAMES["IMAGE"], obj.alt_text]
	else:
		var item_type = get_item_type(obj)
		var text = obj.get("alt_text")
		
		if text == null:
			if obj is RichTextLabel:
				text = obj.get_parsed_text()
			else:
				text = obj.get("text")
			
		if text == null:
			if obj.get("value") != null:
				pass
			
		if text == null || text.strip_edges().is_empty():
			returner = item_type
		else:
			returner = "%s | %s" % [text, item_type]
	
	return returner
	
func get_item_type(obj):
	return obj.get_class()
	
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
	if !parent.select_mode:
		AXController.add_token(parent.SELECT_ENTER)
		parent.select_mode = true
	else:
		AXController.add_token(TYPES[get_parent().name])
		
	for c in AXController._menu_manager._menu_stack:
		c.modulate = Color(0.0, 0.0, 0.0, 0.0)
	Screenreader._clear_redraw = true
	HCController.set_theme()
	update_parent_tab(objects[index])
	redraw_highlighter()
	Screenreader._play_sound("node_select")

func _on_focus_exited() -> void:
	for c in AXController._menu_manager._menu_stack:
		c.modulate = Color(1.0, 1.0, 1.0, 1.0)
		
	HCController.set_theme(AXController._menu_manager._peek_menu())
	Screenreader._play_sound("node_select_exit")
