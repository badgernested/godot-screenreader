class_name Screenreader
extends Object
## This is the class responsible for managing the screenreader.
##
## This class manages the screenreader. You can set some options
## here if you would like to configure the screenreader's functionality.

## Whether or not DOM navigation is enabled.
static var dom_nav_enabled: bool = false

## The object that is referred to as the root of the DOM.
static var dom_root: Node = null

# This stores the list of objects itself. 
static var _objects: Array = []

# Only end node objects list
static var _end_node_list: Array = []

# Only branches that have end nodes
static var _end_node_branches: Array = []

# Keeps track of the array stack
static var _array_stack: Array = []

# This contains a copy of the old "focus mode" state
# this way you can disable DOM mode and go back
# to the focus mode built by the developer
static var _object_focus_mode: Dictionary = {}

## This is the current [Control] in focus.
static var focused: Node = null

# The window is currently in focus in the OS
static var _OS_focused: bool = true

# This is the rect2 of the drawing box for highlighting controls
static var _highlight_box: Rect2 = Rect2(0,0,0,0)

# Is true if the current control is moving and sliding.
static var _slider_moving: bool = false

# Is set to the current text object's text after processing.
static var _last_text: String = ""

# Is set to current caret line for text after processing
static var _last_caret_line: int = 0

# Is set to the last caret position for text after processing
static var _last_caret_pos: int = 0

# This prevents bugs with holding down navigation keys with text
static var _text_wait_to_press: bool = false

# This stores the old value of a slider while sliding
static var _slider_value: float = 0

# This stores whether or not the slider is actually sliding
static var _slider_is_sliding: bool = false

# Checks whether a child popup is visible. gets around weird timing bugs.
static var _popup_visible: bool = false

# Tracks the index of the current popup.
static var _popup_index: int = 0

# The old rect2 of the focused item
static var _focused_old: Control = null

# The last frame's rectangle size for the focused item
static var _focused_rect_old: Rect2 = Rect2(0,0,0,0)

# Whether or not the state was updated.
static var _state_updated: bool = false

# The last scroll value recorded for a tree.
static var _scroll_old: Vector2 = Vector2.ZERO

# When set to true, will redraw next frame
static var _redraw: bool = false

# When set to true, resets redraw before it can occur
static var _clear_redraw: bool = false

# This stores all data objects in the DOM with a dictionary
# that represents certain values.
static var _data_objects: Dictionary = {}

# This is used for inserting accessibility tokens
# to be read by the screenreader
static var _tokens: Array = []

## Movement variables

# Tracks your position navigating end nodes
static var _end_node_position: int = 0

# Timer object for cooldown
static var _timer: Timer = Timer.new()

# Timer for slider cooldown
static var _timer_slider: Timer = Timer.new()

# Timer for slider increment cooldown
static var _timer_slider_increment: Timer = Timer.new()

# How much time to cooldown
const _TIMER_COOLDOWN = 0.3

# How much time to wait before doing slider scrolling
const _TIMER_SLIDER_SCROLL = 0.2

# How much the movement time is modified for the slider
const _MOVEMENT_TIME = 0.000025

# How much pitch shift for list items decrementing
const _LIST_PITCH_SHIFT = 1.2

# Options

## Whether or not sound effects are enabled.
static var sfx_enabled: bool = true

## Whether or not navigation wraps around.
static var navigation_wrap: bool = true

## Whether or not subtitles are enabled
## on [VideoStreamPlayer] Controls.
static var subtitles_enabled: bool = true

## Whether or not audio description is enabled
## on [VideoStreamPlayer] Controls.
static var audio_description_enabled: bool = true

## If this is set to true, the screenreader reads more information
## about each Control.
static var verbose: bool = true

## When enabled, displays debug information in the console.
static var debug: bool = false

# Objects

# Plays sound effects.

static var _sfx : AudioStreamPlayer = AudioStreamPlayer.new()

# Preloaded library of sfx
const _SFX_LIBRARY: Dictionary = {
	"button_down" : preload("res://screenreader/sfx/button_down.wav"),
	"button_up" : preload("res://screenreader/sfx/button_up.wav"),
	"text_enter" : preload("res://screenreader/sfx/text_enter.wav"),
	"text_newline" : preload("res://screenreader/sfx/text_newline.wav"),
	"tab_nav" : preload("res://screenreader/sfx/tab_nav.wav"),
	"slider" : preload("res://screenreader/sfx/slider_change.wav"),
	"slider_move" : preload("res://screenreader/sfx/slider_move.wav"),
	"tree_collapse" : preload("res://screenreader/sfx/tree_collapse.wav"),
	"tree_uncollapse" : preload("res://screenreader/sfx/tree_uncollapse.wav"),
	"tree_enter" : preload("res://screenreader/sfx/tree_enter.wav"),
	"tree_exit" : preload("res://screenreader/sfx/tree_exit.wav"),
	"tree_no_children" : preload("res://screenreader/sfx/tree_no_children.wav"),
	"list_nav" : preload("res://screenreader/sfx/list_nav.wav"),
	"menu_open" : preload("res://screenreader/sfx/menu_open.wav"),
	"menu_close" : preload("res://screenreader/sfx/menu_close.wav"),
	"node_select" : preload("res://screenreader/sfx/node_selector.wav"),
	"node_select_exit" : preload("res://screenreader/sfx/node_select_exit.wav")
}

# Data Strings

const _VIDEO_NAVIGATION_STRINGS = {
	"PLAY" : "Play",
	"PAUSED" : "Paused",
	"STOPPED" : "Stopped"
}
const _MENUBAR_NAVIGATION_STRINGS = {
	"OPENED" : "Opened %s",
	"CLOSED" : "Closed %s"
}

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

const _STRING_FORMATS = {
	"FRACTION" : "%s out of %s",
	"PERCENT" : "%s percent",
	"SELECTED" : "%s selected"
}

const _POPUPMENU_CONTROL_NAMES = {
	"RADIOBUTTON" : "Radio Button",
	"CHECKBOX" : "Checkbox",
	"CHECKED" : "Checked",
	"UNCHECKED" : "Unchecked",
	"ON" : "On",
	"OFF" : "Off"
}

const _TREE_CONTROL_NAMES = {
	"COLLAPSED" : "Collapsed",
	"UNCOLLAPSED" : "Uncollapsed",
	"NO_CHILDREN" : "No children",
	"CHILDREN" : "%s children"
}

# This is used for highlighting UI elements
static var _control_state: int = _CONTROL_STATE.FOCUSED

enum _CONTROL_STATE {
	FOCUSED,
	PRESSED
}

# Strings used in the textedit interfaces
const _TEXTEDIT_STRINGS = {
	"SPACE" : "Space",
	"DELETED" : "Deleted",
	"TAB" : "Tab",
	"ENTER" : "Enter",
	"RELEASED" : "Released",
	"PASTED" : "Pasted",
	"COPIED" : "Copied",
	"NEWLINE" : "New Line",
	"LINE" : "Line Number",
	"NONE" : "None"
}

## Other Enums

# this determines how nodes will be treated and assigned
enum _NODE_TYPE {
	CONTAINER,
	INTERACT_NODE,
	IGNORE
}

## Control methods

# Sets the dom root node.
static func _set_dom_root(obj: Control):
	dom_root = obj
	_init_DOM()

static func _enable_dom(value: bool = true, obj: Control=null):
	dom_nav_enabled = value
	AXController._screenreader_enabled = value
	
	if AXMenuManager._menu_stack.is_empty():
		AXMenuManager._DOM_node = dom_root
	
	# disables godot focus, uses custom UI built
	# in this class
	if dom_nav_enabled:
		_set_focus_off(dom_root)
		# grabs the first active end node
		if obj == null:
			_end_node_position = 0
		else:
			_end_node_position = _end_node_list.find(obj)
			
			if _end_node_position < -1:
				_end_node_position = 0
		_end_node_grab_focus()
	
	# enables dom
	else:
		_set_focus_on(dom_root)
		_clear_DOM()

## Processing/navigation functions

# Processes interacting with inputs
static func _process_input(_delta: float):

	# This prevents bugs caused by switching controls
	var current_focus = focused

	if current_focus != null:
		var default_move = true
		var do_default_processing = true
		var do_screenreader_navigation = true
		
		if current_focus.has_method("ax_function_override"):
			if current_focus.ax_function_override():
				do_default_processing = false
				
		if current_focus.has_method("ax_screenreader_navigation"):
			if !current_focus.ax_screenreader_navigation():
				do_screenreader_navigation = false
		
		if do_default_processing:
			if current_focus is VideoStreamPlayer:
				default_move = _process_video_controls()
			elif current_focus is MenuBar:
				default_move = _process_menubar_controls()
			elif current_focus is TabBar:
				default_move = _process_tabbar_controls()
			elif current_focus is MenuButton:
				default_move = _process_menu_button_controls()
			elif current_focus is OptionButton:
				default_move = _process_option_button_controls()
			elif (current_focus is Button ||
					current_focus is LinkButton ||
					current_focus is TextureButton):
					default_move = _process_button_controls()
			elif (current_focus is HSlider ||
					current_focus is VSlider ||
					current_focus is SpinBox):
				default_move = _process_slider_controls()
			elif (current_focus is LineEdit ||
					current_focus is TextEdit):
				default_move = _process_text_controls()
			elif current_focus is Tree:
				default_move = _process_tree_controls()
		# Processes parent tabbar
		
		if default_move && do_screenreader_navigation:

			var new_movement = 0
			var new_position = -1

			# This does movements between areas
			new_position = _area_movement()
				
			# If able, do the normal tabbing dom movement
			new_movement = _simple_movement()

			if new_movement != 0:
				default_move = false
				_update_end_node_position(new_movement)
			elif new_position > -1:
				default_move = false
				_update_end_node_position(0, new_position)
				
		# If no movement, process information keys
		if default_move:
			default_move = _process_info_keys()
		
# Processes keys for getting information
# like rereading the current element
static func _process_info_keys():
	if Input.is_action_just_pressed("DOM_read_item"):
		_get_accessible_name(focused)
		_tts_speak()
		return false
	
	if Input.is_action_just_pressed("DOM_stop_talk"):
		TTS.stop()
		
	return true

# Button controls
static func _process_button_controls():
	var activated = true
	var toggle_old = focused.button_pressed
	var old_text = focused.text
	
	var current_focus = focused
	
	var pressed = false
	
	var special_press = false
	var special_release = false
	
	if (current_focus is CheckBox
		|| current_focus is CheckButton):
			if (Input.is_action_just_pressed("DOM_item_decrement") ||
				Input.is_action_just_pressed("DOM_item_increment")):
					special_press = true
					
			if (Input.is_action_just_released("DOM_item_decrement") ||
				Input.is_action_just_released("DOM_item_increment")):
					special_release = true
	
	# Allows you to press buttons normally
	if (Input.is_action_just_pressed("ui_accept")
		|| special_press):
		current_focus.emit_signal("button_down")
		_play_sound("button_down")
		_update_draw_state(_CONTROL_STATE.PRESSED)
		activated = false
	elif (Input.is_action_just_released("ui_accept")
		|| special_release):
		current_focus.emit_signal("button_up")
		_play_sound("button_up")
		_update_draw_state(_CONTROL_STATE.FOCUSED)
		activated = false
		
	if current_focus.action_mode == BaseButton.ACTION_MODE_BUTTON_PRESS:
		if Input.is_action_just_pressed("ui_accept") || special_press:
			current_focus.emit_signal("pressed")
			activated = false
			if current_focus.toggle_mode:
				current_focus.button_pressed = !current_focus.button_pressed
			pressed = true
	else:
		if Input.is_action_just_released("ui_accept") || special_release:
			current_focus.emit_signal("pressed")
			activated = false
			if current_focus.toggle_mode:
				current_focus.button_pressed = !current_focus.button_pressed
			pressed = true
			
	if current_focus.toggle_mode:
		if current_focus.button_pressed != toggle_old:
			current_focus.emit_signal("toggled",current_focus.button_pressed)
		
	# If the pressed signal was emitted
	if pressed:
		if current_focus is CheckBox:
			if current_focus.button_pressed:
				_add_token(_POPUPMENU_CONTROL_NAMES["CHECKED"])
			else:
				_add_token(_POPUPMENU_CONTROL_NAMES["UNCHECKED"])
					
		elif current_focus is CheckButton:
			if current_focus.button_pressed:
				_add_token(_POPUPMENU_CONTROL_NAMES["ON"])
			else:
				_add_token(_POPUPMENU_CONTROL_NAMES["OFF"])
		else:
			var alt_text = current_focus.get("alt_text")
			if alt_text == null:
				_add_token(old_text)
			else:
				_add_token(alt_text)
			
		_tts_speak()
	
	return activated 

# Video controls
# returns false if movement is registered
static func _process_video_controls():
	
	var read_text = ""
	
	if Input.is_action_just_pressed("ax_start_video"):
		# Use the ax script, if available.
		# also, it will toggle playback
		if focused.has_method("play_video"):
			if focused.is_playing():
				if focused.paused:
					focused.play_video()
				else:
					focused.pause_video()
			else:
				focused.play_video()
		else:
			if focused.is_playing():
				focused.paused = !focused.paused
				read_text = _VIDEO_NAVIGATION_STRINGS["PAUSED"]
			else:
				focused.play()
				read_text = _VIDEO_NAVIGATION_STRINGS["PLAY"]
		
	elif Input.is_action_just_pressed("ax_stop_video"):
		# Use the ax script, if available.
		if focused.has_method("stop_video"):
			focused.stop_video()
		else:
			focused.stop()
			read_text = _VIDEO_NAVIGATION_STRINGS["STOPPED"]
		
	_tts_speak_direct(read_text)
	
	if !read_text.is_empty():
		return false
				
	return true

# Following are menubar control items

# Does the menubar controls
static func _process_menubar_controls():
	var properties = _get_object_data(focused)
	var menu_pos = 0
	
	if !properties.is_empty():
		menu_pos = properties["selected_menu"]
	
	if menu_pos != null:
		if Input.is_action_just_pressed("DOM_select"):
			# If menu is not opened, open it.
			if !_menubar_menu_opened(focused):
				# opens the currently selected menu
				_menubar_menu_close_all(focused)
				_menubar_menu_open(focused, menu_pos)
				if properties["menu_opened"] != null:
					properties["menu_opened"] = true
					
				var text = _MENUBAR_NAVIGATION_STRINGS["OPENED"] % [focused.get_menu_title(menu_pos)]
				_add_token(text)
				
				var popup = focused.get_menu_popup(menu_pos)
				var selected_pos = properties["selected_index"]
				
				# Which menu item is selected
				text = _STRING_FORMATS["SELECTED"] % popup.get_item_text(selected_pos)
				_add_token(text)
				
				_tts_speak()
				return false
			else:
				# If menu is opened, press the button
				var text = _MENUBAR_NAVIGATION_STRINGS["CLOSED"] % [focused.get_menu_title(menu_pos)]
				_add_token(text)
				
				_tts_speak()
				
				# close menu
				return _menubar_close_menu(properties)
		
		elif Input.is_action_just_pressed("DOM_item_increment"):
			# If menu is not opened, open it.
			if !_menubar_menu_opened(focused):
				# opens the currently selected menu
				_menubar_menu_close_all(focused)
				_menubar_menu_open(focused, menu_pos)
				if properties["menu_opened"] != null:
					properties["menu_opened"] = true
					
				var text = _MENUBAR_NAVIGATION_STRINGS["OPENED"] % [focused.get_menu_title(menu_pos)]
				_add_token(text)
				
				var popup = focused.get_menu_popup(menu_pos)
				var selected_pos = properties["selected_index"]
				
				# Which menu item is selected
				text = _STRING_FORMATS["SELECTED"] % popup.get_item_text(selected_pos)
				_add_token(text)
				
				_tts_speak()
				return false
				
		# closes the menu
		elif (Input.is_action_just_pressed("DOM_cancel")
			|| Input.is_action_just_pressed("DOM_item_decrement")):
			var val = _menubar_close_menu(properties)
			
			var text = _MENUBAR_NAVIGATION_STRINGS["CLOSED"]
			_add_token(text)
			
			_tts_speak()
			
			return val
		
		# If the menu is open, don't navigate, but do read names
		if _menubar_menu_opened(focused):
			if Input.is_action_just_pressed("ui_up"):
				_menubar_read_selected_item(properties)
				_play_sound("list_nav", _LIST_PITCH_SHIFT)
			if Input.is_action_just_pressed("ui_down"):
				_menubar_read_selected_item(properties)
				_play_sound("list_nav")
		
	# Moves around the top menu
	var move = _menubar_nav_menus(properties)
	
	if !move:
		return false
		
	# Disables normal navigation if the menu is opened	
	if _menubar_menu_opened(focused):
		return false
			
	return true

static func _menubar_close_menu(properties: Dictionary):
	# Closes menu if open
	if _menubar_menu_opened(focused):
		_menubar_menu_close_all(focused)
		if properties["menu_opened"] != null:
			properties["menu_opened"] = false
			
		return false

static func _menubar_read_selected_item(properties: Dictionary):
	var menu_pos = properties["selected_menu"]
	
	var popup = focused.get_menu_popup(menu_pos)
	var selected_pos = popup.get_focused_item()
	
	var text = popup.get_item_text(selected_pos)
	_add_token(text)
	
	# Check if menubar is checked and is radio/checkbox
	if popup.is_item_checkable(selected_pos):
		
		# Checked/unchecked token
		if popup.is_item_checked(selected_pos):
			text = _POPUPMENU_CONTROL_NAMES["CHECKED"]
		else:
			text = _POPUPMENU_CONTROL_NAMES["UNCHECKED"]
		_add_token(text)
		
		# Adds if item is checkbox or radio button
		# verbose mode only
		if verbose:
			if popup.is_item_radio_checkable(selected_pos):
				text = _POPUPMENU_CONTROL_NAMES["RADIOBUTTON"]
			else:
				text = _POPUPMENU_CONTROL_NAMES["CHECKBOX"]
				
			_add_token(text)
			
	
	_tts_speak()

static func _menubar_nav_menus(properties: Dictionary):
	var current_focused = focused
	
	if !properties.is_empty():
		if !_menubar_menu_opened(current_focused):
			if Input.is_action_just_pressed("DOM_down"):
				var was_opened = _menubar_menu_opened(current_focused)
				
				var sizer = current_focused.get_menu_count()
				_menubar_menu_close_all(current_focused)

				properties["selected_menu"] += 1

				if properties["selected_menu"] >= sizer:
					properties["selected_menu"] = sizer-1
					if properties["menu_opened"] != null:
						properties["menu_opened"] = false
					_update_end_node_position(1)
				else:
					_end_node_grab_focus()
					
				if was_opened:
					_menubar_menu_open(current_focused, properties["selected_menu"])
				
				if current_focused is MenuBar:
					_get_accessible_menubar_name(current_focused)
					_tts_speak()
					
				_state_updated = true
					
				return false
				
			elif Input.is_action_just_pressed("DOM_up"):
				var was_opened = _menubar_menu_opened(current_focused)
				
				_menubar_menu_close_all(current_focused)
				properties["selected_menu"] -= 1

				if properties["selected_menu"] < 0:
					properties["selected_menu"] = 0
					if properties["menu_opened"] != null:
						properties["menu_opened"] = false
					_update_end_node_position(-1)
				else:
					_end_node_grab_focus()
					
				if was_opened:
					_menubar_menu_open(current_focused, properties["selected_menu"])
					
				if current_focused is MenuBar:
					_get_accessible_menubar_name(current_focused)
					_tts_speak()
					
				_state_updated = true
					
				return false	
			
	return true

static func _menubar_menu_opened(obj: MenuBar):
	var properties = _get_object_data(obj)

	if !properties.is_empty():
		if properties["menu_opened"] != null:
			return properties["menu_opened"]
			
	return false
				
static func _menubar_menu_close_all(obj: MenuBar):
	var properties = _get_object_data(obj)

	var menu_size = focused.get_menu_count()
	
	for c in range(0, menu_size):
		var popup = obj.get_menu_popup(c)
		
		popup.visible = false
	if !properties.is_empty():	
		if properties["selected_index"] != null:
			properties["selected_index"] = 0
	
static func _menubar_menu_update(obj: MenuBar):
	var properties = _get_object_data(obj)
	if !properties.is_empty():
		if properties["selected_index"] != null:
			var popup = obj.get_menu_popup(properties["selected_menu"])
			popup.set_focused_item(properties["selected_index"])
		
static func _menubar_menu_open(obj: MenuBar, index: int):
	var popup = obj.get_menu_popup(index)
	
	popup.visible = true
	
	# Sets position for popup
	
	var h_sep = focused.get_theme_constant("h_separation")

	var length = 0
	var font_size = focused.get_theme_font_size("font_size")
	for c in range(0, index):
		length += focused.get_theme_font("font").get_string_size(
						focused.get_menu_title(c) + " ",
						HORIZONTAL_ALIGNMENT_LEFT,
						-1,
						font_size).x
		
		length += h_sep*2
	
	popup.position = Vector2(focused.global_position.x + float(length),
					focused.global_position.y + font_size * 1.5)
	
	_menubar_menu_update(obj)

# Following are tabbar movement funcionts

static func _process_tabbar_controls():
	var tab_val = focused.current_tab
	var tab_size = focused.tab_count
	
	# Forces navigation for previous
	if Input.is_action_just_pressed("DOM_prev"):
		return true
	
	if Input.is_action_just_pressed("DOM_item_increment"):
		tab_val += 1
		
		if tab_val >= tab_size:
			tab_val = tab_size-1
			focused.current_tab = tab_val
		else:
			focused.current_tab = tab_val
			
		_end_node_grab_focus()
		
		if focused is TabBar:
			_play_sound("tab_nav", 0.75 + (focused.current_tab / tab_size)*0.5)
		
			_get_accessible_tabbar_name(focused)
			_tts_speak()
		
			focused.emit_signal("tab_changed", focused.current_tab)
			focused.emit_signal("tab_selected", focused.current_tab)
			_state_updated = true
			
		return false
		
	elif Input.is_action_just_pressed("DOM_item_decrement"):
		tab_val -= 1
		
		if tab_val < 0:
			tab_val = 0
			focused.current_tab = tab_val
			
		else:
			focused.current_tab = tab_val
			
		_end_node_grab_focus()
		
		if focused is TabBar:
			_play_sound("tab_nav", 0.75 + (focused.current_tab / tab_size)*0.5)
		
			_get_accessible_tabbar_name(focused)
			_tts_speak()
		
			focused.emit_signal("tab_changed", focused.current_tab)
			focused.emit_signal("tab_selected", focused.current_tab)
			_state_updated = true
			
		return false
		
	# If moving to the next element, select the first
	# element in the current panel
	elif (Input.is_action_just_pressed("DOM_next") ||
		Input.is_action_just_pressed("DOM_down")):
		
		var parent = focused.get_parent().get_child(focused.current_tab)
		
		# find the first node with this ancestor in the object list
		for c in range(0,_end_node_list.size()):
			if parent.is_ancestor_of(_end_node_list[c]):
				_update_end_node_position(0, c)
				return false
	
	return true

# Processes slider controls
static func _process_slider_controls():
	
	_sfx.pitch_scale = 0.75 + 0.5 * ((focused.value - focused.min_value) / (focused.max_value - focused.min_value))
	
	# If released, stops slider mode.
	if (!(Input.is_action_pressed("DOM_item_decrement")
		|| Input.is_action_pressed("DOM_item_increment"))
		&& (Input.is_action_just_released("DOM_item_decrement")
		|| Input.is_action_just_released("DOM_item_increment"))):
		_slider_moving = false
		_stop_sound()
		
		# Adds default name tokens if verbose
		# Only reads if _timer is stopped
		if verbose:
			if focused is HSlider:
				_get_accessible_hslider_name(focused)
			elif focused is VSlider:
				_get_accessible_vslider_name(focused)
			elif focused is SpinBox:
				_get_accessible_spinbox_name(focused)
		else:
			_add_token(str(focused.value))
		
		if (focused is HSlider ||
			focused is VSlider):
				focused.emit_signal("drag_ended", _slider_value != focused.value)
		
		_tts_speak()
		
		_timer_slider.stop()
		
		return false
	
	# If pressed down, enters slider mode.
	elif (Input.is_action_just_pressed("DOM_item_decrement")
		|| Input.is_action_just_pressed("DOM_item_increment")):
		_slider_moving = true
		_slider_value = focused.value
		TTS.stop()
		
		# updates slider position
		if Input.is_action_just_pressed("DOM_item_increment"):
			focused.value += focused.step
			focused.emit_signal("value_changed", focused.value)
		elif Input.is_action_just_pressed("DOM_item_decrement"):
			focused.value -= focused.step
			focused.emit_signal("value_changed", focused.value)
		
		_play_sound("slider_move")
		
		_timer_slider.start(_TIMER_SLIDER_SCROLL)
		
		return false
	
	# Only runs if timeout is complete	
	elif _timer_slider.is_stopped():
		var slider_amount = float(focused.max_value - focused.min_value)/float(1.0/focused.step) * _MOVEMENT_TIME
		
		var cooldown = focused.get("cooldown_time")
		
		if cooldown != null && cooldown > 0:
			slider_amount = cooldown
			
		if (Input.is_action_pressed("DOM_item_increment")):
			if !_slider_is_sliding:
				_slider_is_sliding = true
				if (focused is HSlider ||
					focused is VSlider):
						focused.emit_signal("drag_started")
			
			if _timer_slider_increment.is_stopped():
				focused.value += focused.step
				_timer_slider_increment.start(slider_amount)
				focused.emit_signal("value_changed", focused.value)
			return false
			
		elif (Input.is_action_pressed("DOM_item_decrement")):
			if !_slider_is_sliding:
				_slider_is_sliding = true
				if (focused is HSlider ||
					focused is VSlider):
						focused.emit_signal("drag_started")
			
			if _timer_slider_increment.is_stopped():
				focused.value -= focused.step
				_timer_slider_increment.start(slider_amount)
				focused.emit_signal("value_changed", focused.value)
			return false
		
	return true

# Does the text edit controls
static func _process_text_controls():
	_clear_tokens()

	if (Input.is_action_just_pressed("ui_up") ||
		Input.is_action_just_released("ui_up") ||
		Input.is_action_just_pressed("ui_down") ||
		Input.is_action_just_released("ui_down")):
			_text_wait_to_press = true

	var lines_count = 0
	var caret_position = focused.get_caret_column();
	var lines = focused.text.split("\n")
	var last_lines = _last_text.split("\n")
	
	var pitch = 1.0
	
	if focused is TextEdit:
		lines_count = focused.get_caret_line()
	
	# pasted clipboard contents
	if (AXController.key_pressed() && 
		AXController.pressed_keys.has(KEY_CTRL)
		&& AXController.pressed_keys.has(KEY_V)):
		_add_token(DisplayServer.clipboard_get()
			+ " " + _TEXTEDIT_STRINGS["PASTED"])
		_tts_speak()
		return false
	
	# Ignores movement inputs if navigating string with left/right
	if (Input.is_action_pressed("ui_left")
		|| Input.is_action_just_pressed("ui_left")
		|| Input.is_action_pressed("ui_right")
		|| Input.is_action_just_pressed("ui_right")):
			
			var character = ""
			var char_no = 0
			if !lines[lines_count].is_empty():
				if caret_position >= lines[lines_count].length():
					character = lines[lines_count][lines[lines_count].length()-1]
				else:
					character = lines[lines_count][caret_position]
				
				char_no = character.unicode_at(0)
				
			if character == " ":
				character = _TEXTEDIT_STRINGS["SPACE"]
			elif character == "\t":
				character = _TEXTEDIT_STRINGS["TAB"]
				
			# Higher pitched if capital
			if TextFunctions.unicode_is_capital(char_no):
				pitch = 2.0
				
			if _last_caret_pos != caret_position:
				_add_token(TextFunctions.get_character_name(character))
				_tts_speak(pitch)
				
			_last_caret_pos = caret_position
			
			return false
			
	if focused is TextEdit:
		if _text_wait_to_press && (Input.is_action_pressed("ui_up")
			|| Input.is_action_just_pressed("ui_up")):
			# Read the current line
			var character = lines[lines_count]
			var char_no = -1
			if character.length() == 1:
				char_no = character.unicode_at(0)
				
			character = TextFunctions.get_character_name(character)
				
			# Higher pitched if capital
			if TextFunctions.unicode_is_capital(char_no):
				pitch = 2.0
				
			if _last_caret_line == 0:
				return true
				
			_add_token(TextFunctions.get_character_name(character))
				
			if focused is CodeEdit:
				_add_token(str(focused.get_caret_line()+1) + " " + _TEXTEDIT_STRINGS["LINE"])
				
			_tts_speak(pitch)
			_last_caret_line = lines_count
			return false
			
		elif _text_wait_to_press && (Input.is_action_pressed("ui_down")
			|| Input.is_action_just_pressed("ui_down")):
			var character = lines[lines_count]
			var char_no = -1
			if character.length() == 1:
				char_no = character.unicode_at(0)
				
			character = TextFunctions.get_character_name(character)
				
			# Higher pitched if capital
			if character.length() > 1 && char_no > -1 && TextFunctions.unicode_is_capital(char_no):
				pitch = 2.0
				
			if _last_caret_line > lines_count-1:
				return true
				
			# Read the current line
			_add_token(TextFunctions.get_character_name(character))
			
			if focused is CodeEdit:
				_add_token(str(focused.get_caret_line()+1) + " " + _TEXTEDIT_STRINGS["LINE"])
			
			_tts_speak(pitch)
			_last_caret_line = lines_count
			return false
	
	# If a change is made in the text
	if _last_text != focused.text:
		
		if Input.is_key_pressed(KEY_BACKSPACE):
			var character = "" 
			if last_lines[_last_caret_line].length() > 0:
				if lines.size() > _last_caret_line:
					character = last_lines[_last_caret_line][min(caret_position,last_lines[_last_caret_line].length()-1)]
			else:
				character = _TEXTEDIT_STRINGS["NEWLINE"]
			
			_add_token(TextFunctions.get_character_name(character))
				
			_add_token(_TEXTEDIT_STRINGS["DELETED"])
			
		elif Input.is_key_pressed(KEY_SPACE):
			_add_token(_TEXTEDIT_STRINGS["SPACE"])
		
		elif Input.is_key_pressed(KEY_TAB):
			_add_token(_TEXTEDIT_STRINGS["TAB"])
			
		elif (Input.is_key_pressed(KEY_ENTER) ||
				Input.is_key_pressed(KEY_KP_ENTER)):
			_add_token(_TEXTEDIT_STRINGS["ENTER"])
			_play_sound("text_newline")
			
			if focused is CodeEdit:
				_add_token(str(focused.get_caret_line()+1) + " " + _TEXTEDIT_STRINGS["LINE"])
			
		else:
			if !AXController.special_key_combos():
				var character = lines[lines_count][max(caret_position-1,0)]
				var char_no = character.unicode_at(0)
					
				# Higher pitched if capital
				if TextFunctions.unicode_is_capital(char_no):
					pitch = 2.0
		
				_add_token(TextFunctions.get_character_name(character))
				
		_tts_speak(pitch)
		
		_last_text = focused.text
		_last_caret_line = lines_count
		_last_caret_pos = caret_position
		
		return false
		
		
	elif _text_wait_to_press && !AXController.pressed_keys.is_empty() && AXController.key_pressed():
		_clear_tokens()
		
		for c in AXController.pressed_keys:
			_add_token(OS.get_keycode_string(c).replace("Kp","").strip_edges())
		
		_tts_speak()
			
	
	return true

static func _process_menu_button_controls():
	var popup = focused.get_popup()

	var text = focused.text
	
	# this is just for processing basebutton signals
	var toggle_old = focused.button_pressed
	
	# Allows you to press buttons normally
	if Input.is_action_just_pressed("ui_accept"):
		focused.emit_signal("button_down")
	elif Input.is_action_just_released("ui_accept"):
		focused.emit_signal("button_up")
		
	if focused.action_mode == BaseButton.ACTION_MODE_BUTTON_PRESS:
		if Input.is_action_just_pressed("ui_accept"):
			focused.emit_signal("pressed")
			if focused.toggle_mode:
				focused.button_pressed = !focused.button_pressed
	else:
		if Input.is_action_just_released("ui_accept"):
			focused.emit_signal("pressed")
			if focused.toggle_mode:
				focused.button_pressed = !focused.button_pressed
			
	if focused.toggle_mode:
		if focused.button_pressed != toggle_old:
			focused.emit_signal("toggled",focused.button_pressed)
	
	# sets the TTS text to the alt text instead of the menu button text
	if focused.get("alt_text") != null && !focused.alt_text.is_empty():
		text = focused.alt_text

	if _popup_visible:
		var changed = false
		
		if Input.is_action_just_pressed("DOM_up"):
			_popup_index-= 1
			
			if _popup_index < 0:
				_popup_index = 0
				
			_play_sound("list_nav", _LIST_PITCH_SHIFT)
			changed = true
			
		elif Input.is_action_just_pressed("DOM_down"):
			_popup_index += 1
			
			if _popup_index > focused.item_count-1:
				_popup_index = focused.item_count-1

			_play_sound("list_nav")
			changed = true
			
		if changed:
			popup.scroll_to_item(_popup_index)
			popup.set_focused_item(_popup_index)
			
			_add_token(popup.get_item_text(_popup_index))
			_tts_speak()
			
			return false
	
	if Input.is_action_just_pressed("DOM_select"):
		_play_sound("button_down")
		
		if _popup_visible:
			popup.visible = false
			_add_token(_STRING_FORMATS["SELECTED"] % [popup.get_item_text(_popup_index)])
			_popup_index = 0
			_add_token(_MENUBAR_NAVIGATION_STRINGS["CLOSED"] % [text] )
		else:
			focused.emit_signal("about_to_popup")
			focused.show_popup()
			_add_token(popup.get_item_text(_popup_index))
			_add_token(_MENUBAR_NAVIGATION_STRINGS["OPENED"] % [text] )
			
		_popup_visible = !_popup_visible
		
		_tts_speak()
		return false
	
	# Closes menu if open
	if Input.is_action_just_pressed("DOM_item_decrement"):
		if _popup_visible:
			_play_sound("button_down")
			
			popup.visible = false
			_popup_index = 0
			_add_token(_MENUBAR_NAVIGATION_STRINGS["CLOSED"] % [text] )
			
			_popup_visible = !_popup_visible
			
			_tts_speak()
			return false
	
	# Opens menu if not open
	if Input.is_action_just_pressed("DOM_item_increment"):
		if !_popup_visible:
			_play_sound("button_down")
			
			focused.emit_signal("about_to_popup")
			focused.show_popup()
			_add_token(popup.get_item_text(_popup_index))
			_add_token(_MENUBAR_NAVIGATION_STRINGS["OPENED"] % [text] )
				
			_popup_visible = !_popup_visible
			
			_tts_speak()
			return false
		
	if Input.is_action_just_pressed("DOM_cancel"):
		_play_sound("button_down")
		
		if _popup_visible:
			_popup_visible = false
			popup.visible = false
			_popup_index = 0
			_add_token(_MENUBAR_NAVIGATION_STRINGS["CLOSED"] % [text] )
		
		_tts_speak()
		return false

	if Input.is_action_just_released("DOM_select"):
		_play_sound("button_up")
		
	return true

static func _process_option_button_controls():
	var popup = focused.get_popup()

	var text = ""
	
	# this is just for processing basebutton signals
	var toggle_old = focused.button_pressed
	
	# Allows you to press buttons normally
	if Input.is_action_just_pressed("ui_accept"):
		focused.emit_signal("button_down")
	elif Input.is_action_just_released("ui_accept"):
		focused.emit_signal("button_up")
		
	if focused.action_mode == BaseButton.ACTION_MODE_BUTTON_PRESS:
		if Input.is_action_just_pressed("ui_accept"):
			focused.emit_signal("pressed")
			if focused.toggle_mode:
				focused.button_pressed = !focused.button_pressed
	else:
		if Input.is_action_just_released("ui_accept"):
			focused.emit_signal("pressed")
			if focused.toggle_mode:
				focused.button_pressed = !focused.button_pressed
			
	if focused.toggle_mode:
		if focused.button_pressed != toggle_old:
			focused.emit_signal("toggled",focused.button_pressed)
	
	# sets the TTS text to the alt text instead of the menu button text
	if focused.get("alt_text") != null && !focused.alt_text.is_empty():
		text = focused.alt_text

	if _popup_visible:
		var changed = false
		
		if Input.is_action_just_pressed("DOM_up"):
			_popup_index-= 1
			
			if _popup_index < 0:
				_popup_index = 0

			focused.emit_signal("item_focused",_popup_index)
			_play_sound("list_nav", _LIST_PITCH_SHIFT)
			changed = true
			
		elif Input.is_action_just_pressed("DOM_down"):
			_popup_index += 1
			
			if _popup_index > focused.item_count-1:
				_popup_index = focused.item_count-1

			focused.emit_signal("item_focused",_popup_index)
			_play_sound("list_nav")
			changed = true
			
		if changed:
			popup.scroll_to_item(_popup_index)
			popup.set_focused_item(_popup_index)
			
			_add_token(popup.get_item_text(_popup_index))
			_tts_speak()
			
			return false
	
	if Input.is_action_just_pressed("DOM_select"):
		_play_sound("button_down")
		
		if _popup_visible:
			popup.visible = false
			_add_token(_STRING_FORMATS["SELECTED"] % [popup.get_item_text(_popup_index)])
			_add_token(_MENUBAR_NAVIGATION_STRINGS["CLOSED"] % [text] )
			focused.emit_signal("item_selected",_popup_index)
		else:
			focused.show_popup()
			_popup_index = max(focused.selected,0)
			_add_token(popup.get_item_text(_popup_index))
			_add_token(_MENUBAR_NAVIGATION_STRINGS["OPENED"] % [text] )
			
		_popup_visible = !_popup_visible
		
		_tts_speak()
		return false
		
	# Closes the menu if its open
	if Input.is_action_just_pressed("DOM_item_decrement"):
		if _popup_visible:
			_play_sound("button_down")
			
			popup.visible = false
			_add_token(_MENUBAR_NAVIGATION_STRINGS["CLOSED"] % [text] )
			_popup_visible = !_popup_visible
			
			_tts_speak()
			return false
			
	if Input.is_action_just_pressed("DOM_item_increment"):
		if !_popup_visible:
			_play_sound("button_down")
			
			focused.show_popup()
			_popup_index = max(focused.selected,0)
			_add_token(popup.get_item_text(_popup_index))
			_add_token(_MENUBAR_NAVIGATION_STRINGS["OPENED"] % [text] )	
			_popup_visible = !_popup_visible
			
			_tts_speak()
			return false

	if Input.is_action_just_pressed("DOM_cancel"):
		_play_sound("button_down")
		
		if _popup_visible:
			_popup_visible = false
			popup.visible = false
			_popup_index = 0
			_add_token(_MENUBAR_NAVIGATION_STRINGS["CLOSED"] % [text] )
		
		_tts_speak()
		return false

	if Input.is_action_just_released("DOM_select"):
		_play_sound("button_up")
		
	return true

static func _process_tree_controls():
	var treeitem = focused.get_selected() 
	
	if treeitem != null:
		if Input.is_action_just_pressed("DOM_select"):
			if treeitem.get_child_count() > 0:
				treeitem.collapsed = !treeitem.collapsed
				
				if treeitem.collapsed:
					_add_token(_TREE_CONTROL_NAMES["COLLAPSED"])
					_play_sound("tree_collapse")
				else:
					_add_token(_TREE_CONTROL_NAMES["UNCOLLAPSED"])
					_play_sound("tree_uncollapse")
			else:
				_add_token(_TREE_CONTROL_NAMES["NO_CHILDREN"])
				_play_sound("tree_no_children")
		
			_get_accessible_tree_name(focused, false)
		
			_tts_speak()
			_state_updated = true
			return false
			
		if Input.is_action_just_pressed("DOM_item_increment"):
			var next = treeitem.get_next_visible()
			
			if next != null:
				focused.focus_mode = Control.FOCUS_ALL
				focused.grab_focus()
				focused.set_selected(next,0)
				focused.scroll_to_item(next)
				focused.focus_mode = Control.FOCUS_NONE
				_play_sound("list_nav")
				_highlight_tree(focused)
				
			_get_accessible_name(focused)
		
			_tts_speak()
			_state_updated = true
			return false
			
		elif Input.is_action_just_pressed("DOM_item_decrement"):
			var next = treeitem.get_prev_visible()
			
			if next != null:
				focused.focus_mode = Control.FOCUS_ALL
				focused.grab_focus()
				focused.set_selected(next,0)
				focused.scroll_to_item(next)
				focused.focus_mode = Control.FOCUS_NONE
				_play_sound("list_nav",_LIST_PITCH_SHIFT)
				_highlight_tree(focused)
					
			_get_accessible_name(focused)
		
			_tts_speak()
			_state_updated = true
			return false
		
	return true

# Does movement between areas.
# So, for example, if you group buttons together, you can
# tab next-prev between them.
static func _area_movement():
	
	if Input.is_action_just_pressed("DOM_prev"):
		return _find_prev_grouping(focused)
	elif Input.is_action_just_pressed("DOM_next"):
		return _find_next_grouping(focused)
	
	return -1
	
# Finds the next grouping.
# This would be the first valid element of the next available array.
static func _find_next_grouping(obj: Control):
	var pos = _get_node_pos(obj)
	if !pos.is_empty():
		var parent_pos = pos.slice(0,pos.size()-1)
		var parent_obj = _get_node_from_pos(parent_pos)
		var index = _end_node_branches.find(parent_obj)
		
		if index > -1:
			index += 1
			
			if navigation_wrap:
				if index >= _end_node_branches.size():
					index = 0
				elif index < 0:
					index = _end_node_branches.size()-1
			else:
				if index >= _end_node_branches.size():
					index = _end_node_branches.size()-1
				elif index < 0:
					index = 0
					
			var next_obj = _find_first_obj(_end_node_branches[index])
			var next_obj_index = _end_node_list.find(next_obj)
			
			var loops = 0
			
			while !next_obj.is_visible_in_tree():
				index += 1
				
				if navigation_wrap && loops < 2:
					if index >= _end_node_branches.size():
						index = 0
						loops+=1
					elif index < 0:
						index = _end_node_branches.size()-1
						loops+=1
				else:
					if index >= _end_node_branches.size():
						index = _end_node_branches.size()-1
						loops+=1
					elif index < 0:
						index = 0
						loops+=1
						
				next_obj = _find_first_obj(_end_node_branches[index])
				next_obj_index = _end_node_list.find(next_obj)
			
			return next_obj_index
	return -1
	
# Finds the previous grouping.
# This would be the first valid element of the previous available array.
static func _find_prev_grouping(obj: Control):
	var pos = _get_node_pos(obj)
	if !pos.is_empty():
		var parent_pos = pos.slice(0,pos.size()-1)
		var parent_obj = _get_node_from_pos(parent_pos)
		var index = _end_node_branches.find(parent_obj)
		
		if index > -1:
			index -= 1
			
			if navigation_wrap:
				if index >= _end_node_branches.size():
					index = 0
				elif index < 0:
					index = _end_node_branches.size()-1
			else:
				if index >= _end_node_branches.size():
					index = _end_node_branches.size()-1
				elif index < 0:
					index = 0
					
			var next_obj = _find_first_obj(_end_node_branches[index])
			var next_obj_index = _end_node_list.find(next_obj)
			var loops = 0
			
			while !next_obj.is_visible_in_tree():
				index -= 1
				
				if navigation_wrap && loops < 2:
					if index >= _end_node_branches.size():
						index = 0
						loops+=1
					elif index < 0:
						index = _end_node_branches.size()-1
						loops+=1
				else:
					if index >= _end_node_branches.size():
						index = _end_node_branches.size()-1
						loops+=1
					elif index < 0:
						index = 0
						loops+=1
						
				next_obj = _find_first_obj(_end_node_branches[index])
				next_obj_index = _end_node_list.find(next_obj)
			
			return next_obj_index
	return -1
	
	
# Finds the first object in an array	
static func _find_first_obj(arr: Array):
	for c in arr:
		if !(c is Array):
			return c
			
	return null
	
# Returns the first object nested in an array
static func _dig_first_obj(arr: Array):
	for c in arr:
		if !(c is Array):
			return c
		else:
			return _dig_first_obj(c)
			
	return null
			
# Returns false if moved in any way.
# This allows for controls to use basic UI commands to navigate too
static func _simple_movement():

	if !_end_node_list.is_empty():
		
		if Input.is_action_just_pressed("DOM_down"):
			return 1
		elif Input.is_action_just_pressed("DOM_up"):
			return -1

	return 0

# Gets the node position as an array of what indices to take to find it.
static func _get_node_pos(obj: Control):
	var arr = []
		
	_get_node_pos_rec(obj,arr)
				
	return arr
	
static func _get_node_pos_rec(obj: Control, arr:Array=[], search_array: Array=_objects, layer: int = 0):

	arr.append(0)

	for c in search_array:
		if c is Array:
			if _get_node_pos_rec(obj, arr, c, layer+1):
				return true
		else:
			if c == obj:
				return true
		
		arr[layer] +=1
	arr[layer] = 0
	
	arr.remove_at(arr.size() - 1)
	return false
	
# Gets node from given node position array
# returns null if invalid
static func _get_node_from_pos(arr: Array):
	if arr.is_empty():
		return null
	
	var node = _objects[arr[0]]
	
	for c in range(1,arr.size()):
		if node is Array:
			if node.size() > arr[c]:
				node = node[arr[c]]
			else:
				return null
		else:
			return node
		
	return node
	
# The selected end node grabs focus.		
static func _end_node_grab_focus():
	if _end_node_position < _end_node_list.size():
		_grab_obj_focus(_end_node_list[_end_node_position])
	
# This will take the current object and make its tab visible
static func _open_selected_tab(obj: Node):
	var parent = obj.get_parent()
	if parent != null:
		# nearest ancestor tabcontainer is found
		if parent is TabContainer && obj.get_parent().get_children().has(obj):
			parent.current_tab = obj.get_index()
					
		else:
			_open_selected_tab(parent)	
	return null
			
# Moves to a specific end node.
static func _update_end_node(node: Control):
	var index = _end_node_list.find(node)
	
	if index > -1:
		_update_end_node_position(0, index)
			
# Moves to a specific end node position.
static func _update_end_node_position(movement:int = 0, index:int = -1):
	
	focused.release_focus()
	
	# if an exact index is defined, use that
	if index > -1:
		_end_node_position = index
	else:
		_end_node_position+=movement
		
	# Correct navigation position to be within the array
	# If navigation wraps
	if navigation_wrap:
		if _end_node_position >= _end_node_list.size():
			_end_node_position = 0
		elif _end_node_position < 0:
			_end_node_position = _end_node_list.size()-1

	else:
		if _end_node_position >= _end_node_list.size():
			_end_node_position = _end_node_list.size()-1
		elif _end_node_position < 0:
			_end_node_position = 0
		
	if movement > 0:
		var loops = 0
		var next_obj = _end_node_list[_end_node_position]

		while !next_obj.is_visible_in_tree():
			_end_node_position += 1
			
			if navigation_wrap && loops < 2:
				if _end_node_position >= _end_node_list.size():
					_end_node_position = 0
					loops+=1
				elif _end_node_position < 0:
					_end_node_position = _end_node_list.size()-1
					loops+=1
			else:
				if _end_node_position >= _end_node_list.size():
					_end_node_position = _end_node_list.size()-1
					loops+=1
				elif _end_node_position < 0:
					_end_node_position = 0
					loops+=1
					
			next_obj = _end_node_list[_end_node_position]
	elif movement < 0:
		var loops = 0
		var next_obj = _end_node_list[_end_node_position]

		while !next_obj.is_visible_in_tree():
			_end_node_position -= 1
			
			if navigation_wrap && loops < 2:
				if _end_node_position >= _end_node_list.size():
					_end_node_position = 0
					loops+=1
				elif _end_node_position < 0:
					_end_node_position = _end_node_list.size()-1
					loops+=1
			else:
				if _end_node_position >= _end_node_list.size():
					_end_node_position = _end_node_list.size()-1
					loops+=1
				elif _end_node_position < 0:
					_end_node_position = 0
					loops+=1
					
			next_obj = _end_node_list[_end_node_position]
		
	_end_node_grab_focus()
	
	_prdebug("Focus position: %s" % str(_get_node_pos(focused)))

## Focus methods

# Grabs focus of an object
static func _grab_obj_focus(obj: Control):
	if obj != null:
		if dom_nav_enabled:
			
			# Release any sliders
			_slider_moving = false
			_sfx.pitch_scale = 1.0
			_timer_slider.stop()
			_slider_value = 0
			_slider_is_sliding = false
			
			# Clears text
			_last_text = ""
			_last_caret_line = 0
			_text_wait_to_press = false
			
			# Clears a popup if any exists
			_popup_visible = false
			_popup_index = 0
			if focused != null:
				if focused.has_method("get_popup"):
					focused.get_popup().visible = false
				
			# Plays exit sound effects
			
			if focused is Tree:
				_stop_sound()
				_play_sound("tree_exit")
				
			# If it is a progress bar, stop the sound
			if focused is ProgressBar:
				_stop_sound()
			
			# resets state
			_update_draw_state(_CONTROL_STATE.FOCUSED)
			
			var old_focus = focused
			
			if focused != null:
				if focused.has_signal("focus_exited"):
					focused.emit_signal("focus_exited")
					focused.focus_mode = Control.FOCUS_NONE
					
			focused = obj
			
			if focused != null:
				if focused.has_signal("focus_entered"):
					focused.emit_signal("focus_entered")
					
				# If focus is a text box type, play the enter text sound
				if (focused is LineEdit ||
					focused is TextEdit):
						_stop_sound()
						_play_sound("text_enter")
						
						_last_text = focused.text
						# Reset caret position
						focused.set_caret_column(0)
						if focused is TextEdit:
							focused.set_caret_line(0)
							
						
						focused.focus_mode = Control.FOCUS_ALL
						focused.grab_focus()
						
				# If it is the tree type, play an entrance sound
				# and set the selected index to the root if none
				# is selected
				if focused is Tree:
					_stop_sound()
					_play_sound("tree_enter")
					if focused.get_selected() == null:
						focused.set_selected(focused.get_root(),0) 
						
				# If it is a progress bar, play the slider sound
				if focused is ProgressBar:
					_stop_sound()
					_play_sound("slider")
						
			if old_focus != focused:
				# Read the name
				_get_accessible_name(focused)
				_tts_speak()
		else:
			obj.call_deferred("grab_focus")
			
		_open_selected_tab(obj)

		
# Releases focus of an object
static func _release_obj_focus(obj: Control):
	if dom_nav_enabled:
		if focused != null:
			focused.focus_mode = Control.FOCUS_NONE
		focused = null
	obj.release_focus()
	
# Checks the current focused object
static func _check_obj_focus(obj: Control):
	if dom_nav_enabled:
		return obj == focused
		
## Label reading methods

# Gets the name of a control
static func _get_accessible_name(obj:Control):
	
	var name_val = null
	
	if obj.has_method("ax_custom_text"):
		var text = obj.ax_custom_text()
		if !text.is_empty():
			_add_token(text)
			return
	
	if (obj is Label ||
		obj is LineEdit ||
		obj is TextEdit):
		_get_accessible_label_name(obj)
	elif obj is RichTextLabel:
		_get_accessible_richtext_label_name(obj)
	elif obj is OptionButton:
		_get_accessible_optionbutton_name(obj)
	elif (obj is Button
		|| obj is LinkButton):
		_get_accessible_button_name(obj)
	elif (obj is TextureRect):
		_get_accessible_image_name(obj)
	elif (obj is ProgressBar):
		_get_accessible_progress_bar_name(obj)
	elif (obj is SpinBox):
		_get_accessible_spinbox_name(obj)
	elif obj is HSlider:
		_get_accessible_hslider_name(obj)
	elif obj is VSlider:
		_get_accessible_vslider_name(obj)
	elif obj is MenuBar:
		_get_accessible_menubar_name(obj)
	elif obj is TabBar:
		_get_accessible_tabbar_name(obj)
	elif obj is Tree:
		_get_accessible_tree_name(obj)
	else:
		# default name
		if obj.get("alt_text") != null && !obj.alt_text.is_empty():
			name_val = obj.alt_text
			_add_token(name_val)
		else:
			name_val = obj.name
			_add_token(name_val)
			
		if verbose:
			if obj.get_class() != name_val:
				_add_token(obj.get_class())
	
# Gets the name for labels
static func _get_accessible_label_name(obj:Control):
	var name_val = ""

	if focused is CodeEdit:
		var lines = focused.text.split("\n")
		
		_add_token(TextFunctions.get_character_name(lines[focused.get_caret_line()]))
		_add_token(str(focused.get_caret_line()+1) + " " + _TEXTEDIT_STRINGS["LINE"])
	else:
		if ((focused is LineEdit || focused is TextEdit) ||
			!(obj.get("alt_text") != null && !obj.alt_text.is_empty())):
			name_val = obj.text
			_add_token(name_val)
		
	if obj.get("alt_text") != null && !obj.alt_text.is_empty():
		name_val = obj.alt_text
		_add_token(name_val)
		
	if verbose:
		if obj.get_class() != name_val:
			if focused is Label:
				_add_token(_SPECIAL_CONTROL_NAMES["LABEL"])
			else:
				_add_token(obj.get_class()) 
			
# Gets the name for richtext labels
static func _get_accessible_richtext_label_name(obj:Control):
	var name_val = ""
	
	if obj.get("alt_text") != null && !obj.alt_text.is_empty():
		name_val = obj
	else:
		name_val = obj.get_parsed_text()
		
	_add_token(name_val)
			
	if verbose:
		if obj.get_class() != name_val:
			_add_token(_SPECIAL_CONTROL_NAMES["LABEL"])
			
# Gets the name for buttons
static func _get_accessible_button_name(obj:Control):
	var name_val = ""
	
	if obj is CheckBox:
		if obj.button_pressed:
			_add_token(_POPUPMENU_CONTROL_NAMES["CHECKED"])
		else:
			if verbose:
				_add_token(_POPUPMENU_CONTROL_NAMES["UNCHECKED"])
				
	elif obj is CheckButton:
		if obj.button_pressed:
			_add_token(_POPUPMENU_CONTROL_NAMES["ON"])
		else:
			_add_token(_POPUPMENU_CONTROL_NAMES["OFF"])
				
	if obj.get("alt_text") != null && !obj.alt_text.is_empty():
		name_val = obj.alt_text
		_add_token(name_val)
	else:
		name_val = obj.text
		_add_token(name_val)
			
	if verbose:
		if obj.get_class() != name_val:
			var token = _SPECIAL_CONTROL_NAMES["BUTTON"]
			if obj is CheckBox:
				token = _SPECIAL_CONTROL_NAMES["CHECKBOX"]
			elif obj is CheckButton:
				token = _SPECIAL_CONTROL_NAMES["SWITCH"]
			elif obj is MenuButton:
				token = _SPECIAL_CONTROL_NAMES["MENUBUTTON"]
			elif obj is OptionButton:
				token = _SPECIAL_CONTROL_NAMES["DROPDOWN"]
			_add_token(token)
		
# Gets the name for images
static func _get_accessible_image_name(obj:Control):
	var name_val = ""
	
	_add_alt_text(obj)
			
	if verbose:
		if obj.get_class() != name_val:
			_add_token(_SPECIAL_CONTROL_NAMES["IMAGE"])
		
# Gets the name for progress bars
static func _get_accessible_progress_bar_name(obj:Control):
	var name_val = ""
	
	# reads value
	
	if obj.get("read_fraction") != null:
		if obj.read_fraction:
			var text = _STRING_FORMATS["FRACTION"] % [str(obj.value), str(obj.max_value)]
			_add_token(text)
			
		if obj.read_percent:
			var text = _STRING_FORMATS["PERCENT"] % [str(floor(100 * obj.value / obj.max_value))]
			_add_token(text)
	else:
		# default if not accessible script
		var text = _STRING_FORMATS["FRACTION"] % [str(obj.value), str(obj.max_value)]
		_add_token(text)
	
	_add_alt_text(obj)
	
	if verbose:
		if obj.get_class() != name_val:
			_add_token(_SPECIAL_CONTROL_NAMES["PROGRESS_BAR"])
			
# Gets the name for spinboxes
static func _get_accessible_spinbox_name(obj:Control):
	var name_val = ""
	
	# reads value
	_add_token(str(obj.value))
	
	_add_alt_text(obj)
	
	if verbose:
		if obj.get_class() != name_val:
			_add_token(_SPECIAL_CONTROL_NAMES["SPINBOX"])
		
# Gets the name for hslider
static func _get_accessible_hslider_name(obj:Control):
	var name_val = ""
	
	_get_accessible_slider_name(obj)
			
	if verbose:
		if obj.get_class() != name_val:
			_add_token(_SPECIAL_CONTROL_NAMES["HSLIDER"])
			
# Gets the name for vslider
static func _get_accessible_vslider_name(obj:Control):
	var name_val = ""
	
	_get_accessible_slider_name(obj)
			
	if verbose:
		if obj.get_class() != name_val:
			_add_token(_SPECIAL_CONTROL_NAMES["VSLIDER"])
		
static func _get_accessible_slider_name(obj:Control):
	# reads value
	
	if obj.get("read_fraction") != null:
		if obj.read_value:
			_add_token(str(obj.value))
			
		if obj.read_fraction:
			var text = _STRING_FORMATS["FRACTION"] % [str(obj.value), str(obj.max_value)]
			_add_token(text)
			
		if obj.read_percent:
			var text = _STRING_FORMATS["PERCENT"] % [str(floor(100 * obj.value / obj.max_value))]
			_add_token(text)
	else:
		# default if not accessible script
		_add_token(str(obj.value))
	
	_add_alt_text(obj)
		
static func _get_accessible_menubar_name(obj:Control):
	var properties = _get_object_data(obj)
	
	var selected_menu = null
	if properties.has("selected_menu"):
		selected_menu = properties["selected_menu"]
		
	var sizer = obj.get_menu_count()
	var text = ""
	
	if selected_menu == null:
		selected_menu = 0

	if _menubar_menu_opened(obj):
		var selected_index = properties["selected_index"]

		var popup = obj.get_menu_popup(selected_menu)
		var menu_size = popup.item_count
		
		if selected_index == null:
			selected_index = 0
		
		text = popup.get_item_text(selected_index)
		_add_token(text)
		
		# Announce out of 3
		if verbose:
			if selected_menu != null:
				text = _STRING_FORMATS["FRACTION"] % [str(selected_index+1), str(menu_size)]
				_add_token(text)
		
		_add_alt_text(obj)
		
		text = _STRING_FORMATS["SELECTED"] % [popup.name]
		_add_token(text)
	else:
		var popup = obj.get_menu_popup(selected_menu)

		text = _STRING_FORMATS["SELECTED"] % [popup.name]
		_add_token(text)
		
		# Announce out of 3
		if verbose:
			if selected_menu != null:
				text = _STRING_FORMATS["FRACTION"] % [str(selected_menu+1), str(sizer)]
				_add_token(text)
		
		_add_alt_text(obj)
	
	if verbose:
		if obj.get_class() != text:
			_add_token(_SPECIAL_CONTROL_NAMES["MENUBAR"])
	
static func _get_accessible_tabbar_name(obj:Control):

	var selected_menu = obj.current_tab
	var sizer = obj.tab_count
	
	var name_val = obj.get_tab_title(selected_menu)

	var text = _STRING_FORMATS["SELECTED"] % [name_val]
	_add_token(text)
	
	# Announce out of 3
	if verbose:
		text = _STRING_FORMATS["FRACTION"] % [str(selected_menu+1), str(sizer)]
		_add_token(text)
	
	_add_alt_text(obj)
	
	if verbose:
		if obj.get_class() != name_val:
			_add_token(_SPECIAL_CONTROL_NAMES["TABS"])
	
# Gets the name for optionbuttons
static func _get_accessible_optionbutton_name(obj:Control):
	var name_val = ""

	if obj.get_selected_id() > -1:
		_add_token(_STRING_FORMATS["SELECTED"] % [obj.get_item_text(obj.get_selected_id())])
	else:
		_add_token(_STRING_FORMATS["SELECTED"] % [_TEXTEDIT_STRINGS["NONE"]])
		
	if obj.get("alt_text") != null && !obj.alt_text.is_empty():
		name_val = obj.alt_text
		_add_token(name_val)
		
	if verbose:
		if obj.get_class() != name_val:
			if obj is Label:
				_add_token(_SPECIAL_CONTROL_NAMES["LABEL"])
			else:
				_add_token(obj.get_class()) 
	
static func _get_accessible_tree_name(obj:Control, read_collapse:bool = true):
	
	# Read off the currently selected node, if any
	var selected_item = obj.get_selected()
	if selected_item != null:
		_add_token(_STRING_FORMATS["SELECTED"] % [selected_item.get_text(0)])
	else:
		_add_token(_STRING_FORMATS["SELECTED"] % [_TEXTEDIT_STRINGS["NONE"]])

	if selected_item != null:
		if selected_item.collapsed:
			if read_collapse:
				_add_token(_TREE_CONTROL_NAMES["COLLAPSED"])
		else:
			var child_count = selected_item.get_child_count()
				
			if child_count > 0:
				_add_token(_TREE_CONTROL_NAMES["CHILDREN"] % [str(child_count)])
			else:
				_add_token(_TREE_CONTROL_NAMES["NO_CHILDREN"])
		
	var name_val = ""
	
	if obj.get("alt_text") != null && !obj.alt_text.is_empty():
		name_val = obj.alt_text
		_add_token(name_val)
	
	if verbose:
		if obj.get_class() != name_val:
				_add_token(obj.get_class()) 
	
# adds alt text	
static func _add_alt_text(obj:Control):
	var name_val = ""
	
	# reads alt text, if any
	if obj.get("alt_text") != null && !obj.alt_text.is_empty():
		name_val = obj.alt_text
		_add_token(name_val)

## Tree Building Methods

# Searches the tree starting at this node for UI elements to grab
static func _recursive_tree_search(obj:Control, level:int = 0):
	var current_objects;
		
	var created = 0;
	if _is_marked_container(obj) == 1 || _if_parent_is_TabContainer(obj):
		current_objects = _array_stack[_array_stack.size()-1]
		var new_array = []
		_array_stack.append(new_array)
		current_objects.append(new_array)
		created += 1
		
	current_objects = _array_stack[_array_stack.size()-1]
		
	# Inserts under special conditions
	var node_type = _get_node_type(obj)
	
	if ((node_type == _NODE_TYPE.INTERACT_NODE
		&& obj.get("ignore") != true)
		|| obj.get("custom_control")):
			
		current_objects.append(obj)
		
		if obj is MenuBar:
			_insert_menubar(obj)
		
		# Tab bars add their children instead
		if obj is TabBar:
			var new_array = []
			_array_stack.append(new_array)
			current_objects.append(new_array)
			# Go deeper in the recursion
			for c in obj.get_parent().get_children(true):
				if obj != c:
					_recursive_tree_search(c,level+1)
			
			_array_stack.pop_back()
			return true

	# If the node is not an end node
	if (node_type != _NODE_TYPE.INTERACT_NODE
		&& !obj.get("custom_control")):
		# If the object has children
		if obj.get_child_count(true) > 0:
			# Go deeper in the recursion
			for c in obj.get_children(true):
				
				# if node is not programmic (unless tabbar
				if !obj.name.contains("@") || obj is TabBar:
					if c is Control:
						if _recursive_tree_search(c,level+1):
							break
					else:
						break
	
	for c in range(0,created):			
		_array_stack.pop_back()
		
	return false

## TTS management methods

# Clear tokens
static func _clear_tokens():
	_tokens = []
	
# adds token
static func _add_token(token: String):
	token = token.strip_edges()
	if token == ")":
		pass
	
	if(!token.is_empty()):
		_tokens.append(token)
		
# Speaks the current token state
static func _tts_speak(pitch:float = 1.0,rate: float = 1.0, volume: int = 50):
	if _tokens.is_empty():
		return
	
	var text = _get_tokens()
		
	_tts_speak_direct(text, pitch, rate, volume)
	
# Speaks the current token state
static func _get_tokens():
	var text = ""
	for c in _tokens:
		if !c.strip_edges().is_empty():
			text += c + " | "
		
	_clear_tokens()
	
	return text
	
static func _tts_speak_direct(text: String, pitch:float = 1.0,rate:float= 1.0 ,volume:int = 50):
	if !text.is_empty():
		TTS.stop()
		TTS.speak(text, false, TTS.default_lang, pitch, rate, volume)
		
		_timer.start(_TIMER_COOLDOWN)
		
static func _is_cooled_down():
	return _timer.is_stopped()

# Function to check if parent is tab container
static func _if_parent_is_TabContainer(obj:Control):
	if obj.get_parent() is TabContainer && obj.get_parent().get_children().has(obj):
		return true
	else:
		return false

# Returns if the container is marked to be used as
# a container in the list.
# Returns 1 = true, 0 = false, -1 no property found
static func _is_marked_container(obj:Control):
	if obj.get("focus_marked_container") != null:
		if obj.focus_marked_container && _get_node_type(obj) == _NODE_TYPE.CONTAINER:
			return 1
		return 0
			
	return -1

# Function to determine if list item is category or end item
static func _get_node_type(obj:Control):
	
	# Returns if the node is an end node
	if (obj is Button 
			|| obj is LinkButton
			|| obj is Label
			|| obj is LineEdit
			|| obj is TextEdit
			|| obj is RichTextLabel
			|| obj is ProgressBar
			|| obj is SpinBox
			|| obj is HSlider
			|| obj is VSlider
			|| obj is TabBar
			|| obj is VideoStreamPlayer
			|| obj is Tree
			|| obj is MenuBar
			|| (obj is TextureRect && obj.get("alt_text") != null)):
				return _NODE_TYPE.INTERACT_NODE
	
	if (obj is Panel ||
		is_instance_of(obj, Control)):
			return _NODE_TYPE.CONTAINER
	
	return _NODE_TYPE.IGNORE

# Gets the object list but with no tree structure

static func _get_object_list(list: Array = _objects):
	for c in list:
		if c is Array:
			_get_object_list(c)
		else:
			if (_get_node_type(c) == _NODE_TYPE.INTERACT_NODE
				|| c.get("custom_control")):
				_end_node_list.append(c)
				if !_end_node_branches.has(list):
					_end_node_branches.append(list)

# gets the Focus Modes of all child elements

static func _build_focus_mode_list():
	_object_focus_mode = {}
	
	_get_focus_mode_rec(dom_root, _object_focus_mode)
	
# recursive function to get focus mode
static func _get_focus_mode_rec(obj: Control, dic:Dictionary):
	for c in obj.get_children(true):
		if c is Control:
			dic[c] = c.focus_mode
			
			if c.get_child_count(true) > 0:
				_get_focus_mode_rec(c, dic)

# Sets all the focus objects to have no focus mode
static func _set_focus_off(obj:Control):
	if obj != null:
		for c in obj.get_children(true):
			if c is Control:
				if c.get("enable_mouse") == true:
					c.focus_mode = Control.FOCUS_CLICK
				else:
					c.focus_mode = Control.FOCUS_NONE
				
				if c.get_child_count(true) > 0:
					_set_focus_off(c)
				
static func _set_focus_on(obj:Control, dir:Dictionary = _object_focus_mode):
	if obj != null && !_object_focus_mode.is_empty():
		for c in obj.get_children(true):
			if c is Control:
				if dir.has(c):
					c.focus_mode =dir[c]
					
				_set_focus_on(c,dir)	
				
	focused = null
	_focused_old = null

# Highligher Functions

# Updates the draw highlighter
static func _update_draw_highlight(obj=focused):

	if dom_root == null || !is_instance_valid(obj):
		_clear_highlight()
	else:
		if obj.get("draw_highlight") != null:
			if !obj.draw_highlight:
				return
		
		if obj is MenuBar:
			_highlight_menubar(obj)
		elif obj is TabBar:
			_highlight_tabbar(obj)
		elif obj is Tree:
			_highlight_tree(obj)
		else:
			_highlight_normal(obj)

# clears highlight
static func _clear_highlight():
	_highlight_box = Rect2(-200,-200,1,1)

# redraws based on menu position
static func _highlight_normal(obj):
	_highlight_box = Rect2(obj.get_global_rect())
	
# redraws based on menubar
static func _highlight_menubar(obj):
	var properties = _get_object_data(obj)
	
	var box = obj.get_global_rect()
	
	var selected = null
	if properties.has("selected_menu"):
		selected = properties["selected_menu"]
	
	var menu_count = obj.get_menu_count()
	
	# This will indicate that accessibility is not configued properly.
	# make sure you add the script
	if selected == null || menu_count < 1:
		_highlight_box = Rect2(box)
	else:

		var h_sep = obj.get_theme_constant("h_separation")
		var stylebox = obj.get_theme_stylebox("normal")
		
		var perm1 = Vector2.ZERO
		var perm2 = Vector2.ZERO
		
		if stylebox is StyleBoxFlat:
			perm1.x += stylebox.border_width_left
			perm1.y += stylebox.border_width_top
			perm2.x += stylebox.border_width_right
			perm2.y += stylebox.border_width_bottom

		var length = 0
		var font_size = obj.get_theme_font_size("font_size")
		for c in range(0, selected):
			length += obj.get_theme_font("font").get_string_size(
							obj.get_menu_title(c) + " ",
							HORIZONTAL_ALIGNMENT_LEFT,
							-1,
							font_size).x
			
			length += (h_sep + floor((perm1.x+perm1.y)*0.5))*2

		var sizer = obj.get_theme_font("font").get_string_size(
						obj.get_menu_title(selected) + " ",
						HORIZONTAL_ALIGNMENT_LEFT,
						-1,
						font_size)
		
		_highlight_box = Rect2(obj.global_position.x + float(length) * (box.size.x / focused.size.x),
								obj.global_position.y,
								(sizer.x + h_sep + (perm1.x + perm1.y)) * (box.size.x / focused.size.x),
								(sizer.y + font_size*0.5 + perm1.y + perm2.y)  * (box.size.y / focused.size.y))
	
# redraws based on tabbar
static func _highlight_tabbar(obj):
		
	var box = obj.get_global_rect()
		
	var tab_rect = obj.get_tab_rect(obj.current_tab)
		
	_highlight_box = Rect2(
		obj.global_position.x + tab_rect.position.x  * (box.size.x / obj.size.x),
		obj.global_position.y + tab_rect.position.y  * (box.size.y / obj.size.y),
		tab_rect.size.x * (box.size.x / obj.size.x),
		tab_rect.size.y * (box.size.y / obj.size.y)
	)
	
static func _highlight_tree(obj):
	
	
	var v = obj.get_theme_constant("v_separation")
	
	var item = obj.get_selected()
	
	var stylebox = obj.get_theme_stylebox("normal")
	
	var perm1 = Vector2.ZERO
	var perm2 = Vector2.ZERO
	
	if stylebox is StyleBoxFlat:
		perm1.x += stylebox.content_margin_left
		perm1.y += stylebox.content_margin_top
		perm2.x += stylebox.content_margin_right
		perm2.y += stylebox.content_margin_bottom
	
	if item == null:
		_highlight_normal(obj)
	else:
		var box = obj.get_global_rect()
		var y_multi = (box.size.y / obj.size.y)
		
		_highlight_box = obj.get_item_area_rect(item)

		_highlight_box.position.y = _highlight_box.position.y * y_multi + perm1.y
		
		_highlight_box.size.x = _highlight_box.size.x * (box.size.x / obj.size.x)
		_highlight_box.size.y = _highlight_box.size.y * y_multi


		_highlight_box.position += obj.global_position
		_highlight_box.position.y -= obj.get_scroll().y  * y_multi
		_highlight_box.size.y += v*2 * y_multi
		
		if obj.global_position.y > _highlight_box.position.y:
			_highlight_box.position.y = obj.global_position.y
			_highlight_box.size.y = 6
			
		if obj.global_position.y + box.size.y < _highlight_box.position.y:
			_highlight_box.position.y = obj.global_position.y + box.size.y
			_highlight_box.size.y = 6
	
# Sound functions

# Note, this sound object only 

# Init functions here, stuff like audio bank can be set.
static func _sound_init(obj: Control):
	obj.add_child(_sfx)

# plays a sound effect
# only from preloaded assets in _SFX_LIBRARY
static func _play_sound(name_val: String, pitch: float = 1.0):
	if sfx_enabled:
		if _SFX_LIBRARY.has(name_val):
			_sfx.stream = _SFX_LIBRARY[name_val]
			_sfx.pitch_scale = pitch
			_sfx.play()
		
# stops a sound effect
static func _stop_sound():
	_sfx.stop()
	
# Starts playing the sound for the slider
static func _timer_slider_timeout():
	_play_sound("slider")
	
# Menubar Object Tracker functions

# Gets the object from object data reference
static func _get_object_data(obj: Control):
	if _data_objects.has(obj):
		return _data_objects[obj]
	return {}

# Inserts menubar data into the dictionary
static func _insert_menubar(obj: MenuBar):
	_data_objects[obj] = _create_menubar_object()

# This creates a new initialized menubar info object
static func _create_menubar_object():
	return {
		"selected_menu" : 0,
		"selected_index" : 0,
		"menu_opened" : false
	}
	
# Updates what state to draw the current control in
static func _update_draw_state(state: _CONTROL_STATE):
	_control_state = state
	
# Initializer Functions

# Gets the DOM state populated
static func _init_DOM():
	
	_set_focus_on(dom_root)
	
	_clear_DOM()
	
	if dom_root != null:
		_recursive_tree_search(dom_root)
		_get_object_list()
		_build_focus_mode_list()
	
static func _clear_DOM():
	_objects = []
	_end_node_list = []
	_end_node_branches = []
	_data_objects = {}
	_array_stack = [_objects]
	
static func _prdebug(string: String):
	if debug:
		print_debug(string)
		
# Inherited functions

# Runs when intialized
static func _do_ready(obj: Node):
	# Makes it so that the selector always is drawn over the UI elements
	obj.z_index = 100
	_timer.one_shot = true
	_timer_slider.one_shot = true
	_timer_slider_increment.one_shot = true
	
	_timer_slider.connect("timeout", _timer_slider_timeout)
	obj.add_child(_timer)
	obj.add_child(_timer_slider)
	obj.add_child(_timer_slider_increment)
	_sound_init(obj)

# This forces reading the contents to override anything else.
static func _do_input(event: InputEvent):
	if dom_nav_enabled:
		if event is InputEventMouseButton:
			if focused is Tree:
				if (event.button_index == MOUSE_BUTTON_WHEEL_DOWN
					|| event.button_index == MOUSE_BUTTON_WHEEL_UP):
						_state_updated = true
						
	return false

# Processes the inputs for the DOM object
static func _do_process(delta: float) -> void:
	_process_input(delta)
	
	if focused != null:
		if (_focused_old != focused):
			_redraw = true
		elif (_focused_rect_old != focused.get_global_rect()):
			_redraw = true
		elif _state_updated:
			_redraw = true
		elif focused is Tree:
			if focused.get_scroll() != _scroll_old:
				_scroll_old = focused.get_scroll()
				_redraw = true
	
	if is_instance_valid(focused):
		if focused is ProgressBar:
			var perc = (focused.value - focused.min_value) / (focused.max_value - focused.min_value);
			
			_sfx.pitch_scale = 0.75 + perc * 0.5
		
	_state_updated = false
	
	if focused != null:
		_focused_old = focused
		_focused_rect_old = focused.get_global_rect()
	
## Notification

static func _do_notification(what: int):
	if what == Control.NOTIFICATION_APPLICATION_FOCUS_OUT:
		TTS.stop()
		_OS_focused = false
		# If MenuBar is access enabled, closes the menu variables
		if is_instance_valid(focused):
			if focused is MenuBar:
				if focused.get("selected_index") != null:
					focused.selected_index = 0
					focused.menu_opened = false
				
		# Clears popup variables
		_popup_visible = false
		_popup_index = 0
				
	if what == Control.NOTIFICATION_APPLICATION_FOCUS_IN:
		_OS_focused = true
		
	if what == Control.NOTIFICATION_EXIT_TREE:
		TTS.stop()
