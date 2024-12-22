extends "res://screenreader/scripts/object_scripts/ax_label.gd"

var _triggered_this_frame = false

# If this value returns a non-empty value, it will read that
# string instead of the default string for the screenreader
# when it reads its name.
func ax_custom_text() -> String:
	return text

# When this function returns true, it will override 
# the regular input function of the control.
# Note that this will require you to manually 
# insert all emit_signal calls.
func ax_function_override():
	if Input.is_action_just_pressed("DOM_item_decrement"):
		var tabbar = _get_tabbar(self)
		
		var index = tabbar.current_tab - 1
		
		if index >= tabbar.tab_count:
			index = tabbar.tab_count - 1
			goto_button()
			return false
		elif index < 0:
			index = 0
			
		tabbar.current_tab = index
		
		_triggered_this_frame = true
		
		update_tab_position(tabbar)
		return true
	elif Input.is_action_just_pressed("DOM_item_increment"):
		var tabbar = _get_tabbar(self)
		
		var index = tabbar.current_tab + 1
		
		if index >= tabbar.tab_count:
			index = tabbar.tab_count - 1
			goto_button()
			return false
		elif index < 0:
			index = 0
			
		tabbar.current_tab = index
		
		_triggered_this_frame = true
		
		update_tab_position(tabbar)
		return true
	
	return false
	
# If this method returns true, the default screenreader
# navigation functionality will still be called.
# Typically if you did some other functionality this frame,
# you don't want to trigger navigation too. So make this
# return false if you trigger functionality this frame.
func ax_screenreader_navigation():
	if _triggered_this_frame:
		_triggered_this_frame = false
		return false
		
	return true

# Gets the parent tab bar from this element	
func _get_tabbar(obj) -> TabBar:
	var parent = obj.get_parent()
	
	if parent == null:
		return null
	else:
		if parent is TabContainer:
			var tabb = parent.get_child(0, true)
			if tabb is TabBar:
				return tabb
		else:
			return _get_tabbar(parent)
	
	return null
	
# Gets the first selectable object index from a tabbar.
func get_first_of_tabbar(obj: TabBar) -> int:
	var tab_arr = []
	
	for c in Screenreader._end_node_branches:
		if c.has(obj):
			tab_arr = c
			break

	if !tab_arr.is_empty():
		var item_arr = tab_arr[1]
		
		var obj_dig = Screenreader._dig_first_obj(item_arr[obj.current_tab])
		
		return Screenreader._end_node_list.find(obj_dig)
		
	return -1

# Updates the tab position
# You have to add a slight delay to prevent a flashing bug.
func update_tab_position(tabbar: TabBar):
	await get_tree().create_timer(0.001).timeout
	Screenreader._update_end_node_position(0,get_first_of_tabbar(tabbar))
	
# Updates the tab position
# You have to add a slight delay to prevent a flashing bug.
func goto_button():
	await get_tree().create_timer(0.001).timeout
	# Finds the button
	var butt = null
	
	for c in range(0,Screenreader._end_node_list.size()):
		if Screenreader._end_node_list[c].name == "FinishButton":
			butt = c
			break
	
	Screenreader._update_end_node_position(0, butt)
