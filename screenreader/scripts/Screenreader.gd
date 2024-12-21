###############################################
# Screenreader
#
# The screenreader class.
###############################################

class_name Screenreader
extends Control

## Variables

# Whether or not DOM navigation is enabled
static var dom_nav_enabled: bool = false

# The object that is referred to as the root of the Dom.
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
static var _object_focus_mode: Array = []

# This is the current object in focus
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
const TIMER_COOLDOWN = 0.3

# How much time to wait before doing slider scrolling
const TIMER_SLIDER_SCROLL = 0.2

# How much the movement time is modified for the slider
const MOVEMENT_TIME = 0.000025

# How much pitch shift for list items decrementing
const LIST_PITCH_SHIFT = 1.2

# Options

# Whether or not sound effects are enabled
static var sfx_enabled: bool = true

# whether or not navigation wraps around
static var navigation_wrap: bool = true

# whether or not subtitles are enabled
static var subtitles_enabled: bool = true

# whether or not audio description is enabled
static var audio_description_enabled: bool = true

# if true, reads more detailed strings
static var verbose: bool = true

# This shows useful debug messages if enabled
static var debug: bool = false

# Objects

# Plays sound effects.

static var _sfx : AudioStreamPlayer = AudioStreamPlayer.new()

# Preloaded library of sfx
const SFX_LIBRARY = {
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
	"list_nav" : preload("res://screenreader/sfx/list_nav.wav")
}

# Data Strings

const VIDEO_NAVIGATION_STRINGS = ["Play", "Paused", "Stopped"]
enum VIDEO_NAVIGATION {
	PLAY,
	PAUSED,
	STOPPED
}

const MENUBAR_NAVIGATION_STRINGS = ["Opened %s", "Closed %s"]
enum MENUBAR_NAVIGATION {
	OPENED,
	CLOSED
}

const SPECIAL_CONTROL_NAMES = ["Image", "Progress Bar", "Horizontal Slider",
								"Vertical Slider", "Spinbox", "Label", "Button",
								"Menu Bar", "Tabs", "Check Box", "Switch",
								"Menu Button", "Dropdown"]
enum SPECIAL_CONTROLS {
	IMAGE,
	PROGRESS_BAR,
	HSLIDER,
	VSLIDER,
	SPINBOX,
	LABEL,
	BUTTON,
	MENUBAR,
	TABS,
	CHECKBOX,
	SWITCH,
	MENUBUTTON,
	DROPDOWN
}

const STRING_FORMATS = ["%s out of %s", "%s percent", "%s selected"]
enum STRING_FORMAT {
	FRACTION,
	PERCENT,
	SELECTED
}

const POPUPMENU_CONTROL_NAMES = ["Radio Button", "Checkbox", "Checked",
								"Unchecked", "On", "Off"]
enum POPUPMENU_CONTROL {
	RADIOBUTTON,
	CHECKBOX,
	CHECKED,
	UNCHECKED,
	ON,
	OFF
}

const TREE_CONTROL_NAMES = ["Collapsed", "Uncollapsed", "No children", "%s children"]
enum TREE_CONTROL {
	COLLAPSED,
	UNCOLLAPSED,
	NO_CHILDREN,
	CHILDREN
}

# This is used for highlighting UI elements
static var _control_state: int = CONTROL_STATE.FOCUSED

enum CONTROL_STATE {
	FOCUSED,
	PRESSED
}

# Strings used in the textedit interfaces
const TEXTEDIT_STRINGS = ["Space", "Deleted", "Tab", "Enter", "Released", "Pasted",
							"Copied", "New Line", "Line Number", "None"]
enum TEXTEDIT_STRING {
	SPACE,
	DELETED,
	TAB,
	ENTER,
	RELEASED,
	PASTED,
	COPIED,
	NEWLINE,
	LINE,
	NONE
}

## Other Enums

# this determines how nodes will be treated and assigned
enum NODE_TYPE {
	CONTAINER,
	INTERACT_NODE,
	IGNORE
}

## Control methods

# Sets the dom root node.
static func set_dom_root(obj):
	dom_root = obj
	init_DOM()

static func enable_dom(value=true):
	dom_nav_enabled = value
	
	# disables godot focus, uses custom UI built
	# in this class
	if dom_nav_enabled:
		_set_focus_off(dom_root)
		# grabs the first active end node
		_end_node_grab_focus()
	
	# enables dom
	else:
		_set_focus_on(dom_root)

## Processing/navigation functions

# Processes interacting with inputs
static func _process_input(_delta):

	if focused != null:
		var default_move = true
		var do_default_processing = true
		var do_screenreader_navigation = true
		
		if focused.has_method("ax_function_override"):
			if focused.ax_function_override():
				do_default_processing = false
				
		if focused.has_method("ax_screenreader_navigation"):
			if !focused.ax_screenreader_navigation():
				do_screenreader_navigation = false
		
		if do_default_processing:
			if focused is VideoStreamPlayer:
				default_move = _process_video_controls()
			elif focused is MenuBar:
				default_move = _process_menubar_controls()
			elif focused is TabBar:
				default_move = _process_tabbar_controls()
			elif focused is MenuButton:
				default_move = _process_menu_button_controls()
			elif focused is OptionButton:
				default_move = _process_option_button_controls()
			elif (focused is Button ||
					focused is LinkButton ||
					focused is TextureButton):
					default_move = _process_button_controls()
			elif (focused is HSlider ||
					focused is VSlider ||
					focused is SpinBox):
				default_move = _process_slider_controls()
			elif (focused is LineEdit ||
					focused is TextEdit):
				default_move = _process_text_controls()
			elif focused is Tree:
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
		get_accessible_name(focused)
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
	
	var pressed = false
	
	# Allows you to press buttons normally
	if Input.is_action_just_pressed("ui_accept"):
		focused.emit_signal("button_down")
		_play_sound("button_down")
		_update_draw_state(CONTROL_STATE.PRESSED)
		activated = false
	elif Input.is_action_just_released("ui_accept"):
		focused.emit_signal("button_up")
		_play_sound("button_up")
		_update_draw_state(CONTROL_STATE.FOCUSED)
		activated = false
		
	if focused.action_mode == BaseButton.ACTION_MODE_BUTTON_PRESS:
		if Input.is_action_just_pressed("ui_accept"):
			focused.emit_signal("pressed")
			activated = false
			if focused.toggle_mode:
				focused.button_pressed = !focused.button_pressed
			pressed = true
	else:
		if Input.is_action_just_released("ui_accept"):
			focused.emit_signal("pressed")
			activated = false
			if focused.toggle_mode:
				focused.button_pressed = !focused.button_pressed
			pressed = true
			
	if focused.toggle_mode:
		if focused.button_pressed != toggle_old:
			focused.emit_signal("toggled",focused.button_pressed)
		
	# If the pressed signal was emitted
	if pressed:
		if focused is CheckBox:
			if focused.button_pressed:
				_add_token(POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.CHECKED])
			else:
				_add_token(POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.UNCHECKED])
					
		elif focused is CheckButton:
			if focused.button_pressed:
				_add_token(POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.ON])
			else:
				_add_token(POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.OFF])
		else:
			var alt_text = focused.get("alt_text")
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
				read_text = VIDEO_NAVIGATION_STRINGS[VIDEO_NAVIGATION.PAUSED]
			else:
				focused.play()
				read_text = VIDEO_NAVIGATION_STRINGS[VIDEO_NAVIGATION.PLAY]
		
	elif Input.is_action_just_pressed("ax_stop_video"):
		# Use the ax script, if available.
		if focused.has_method("stop_video"):
			focused.stop_video()
		else:
			focused.stop()
			read_text = VIDEO_NAVIGATION_STRINGS[VIDEO_NAVIGATION.STOPPED]
		
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
					
				var text = MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.OPENED] % [focused.get_menu_title(menu_pos)]
				_add_token(text)
				
				var popup = focused.get_menu_popup(menu_pos)
				var selected_pos = properties["selected_index"]
				
				# Which menu item is selected
				text = STRING_FORMATS[STRING_FORMAT.SELECTED] % popup.get_item_text(selected_pos)
				_add_token(text)
				
				_tts_speak()
				return false
			else:
				# If menu is opened, press the button
				var text = MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.CLOSED] % [focused.get_menu_title(menu_pos)]
				_add_token(text)
				
				_tts_speak()
				
				# close menu
				return _menubar_close_menu(properties)
				
		elif Input.is_action_just_pressed("DOM_cancel"):
			var val = _menubar_close_menu(properties)
			
			var text = MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.CLOSED]
			_add_token(text)
			
			_tts_speak()
			
			return val
		
		# If the menu is open, don't navigate, but do read names
		if _menubar_menu_opened(focused):
			if Input.is_action_just_pressed("ui_up"):
				_menubar_read_selected_item(properties)
				_play_sound("list_nav", LIST_PITCH_SHIFT)
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

static func _menubar_close_menu(properties):
	# Closes menu if open
	if _menubar_menu_opened(focused):
		_menubar_menu_close_all(focused)
		if properties["menu_opened"] != null:
			properties["menu_opened"] = false
			
		return false

static func _menubar_read_selected_item(properties):
	var menu_pos = properties["selected_menu"]
	
	var popup = focused.get_menu_popup(menu_pos)
	var selected_pos = popup.get_focused_item()
	
	var text = popup.get_item_text(selected_pos)
	_add_token(text)
	
	# Check if menubar is checked and is radio/checkbox
	if popup.is_item_checkable(selected_pos):
		
		# Checked/unchecked token
		if popup.is_item_checked(selected_pos):
			text = POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.CHECKED]
		else:
			text = POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.UNCHECKED]
		_add_token(text)
		
		# Adds if item is checkbox or radio button
		# verbose mode only
		if verbose:
			if popup.is_item_radio_checkable(selected_pos):
				text = POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.RADIOBUTTON]
			else:
				text = POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.CHECKBOX]
				
			_add_token(text)
			
	
	_tts_speak()

static func _menubar_nav_menus(properties):
	if !properties.is_empty():
		if Input.is_action_just_pressed("DOM_item_increment"):
			var was_opened = _menubar_menu_opened(focused)
			
			var sizer = focused.get_menu_count()
			_menubar_menu_close_all(focused)

			properties["selected_menu"] += 1

			if properties["selected_menu"] >= sizer:
				properties["selected_menu"] = sizer-1
				if properties["menu_opened"] != null:
					properties["menu_opened"] = false
				_update_end_node_position(1)
			else:
				_end_node_grab_focus()
				
			if was_opened:
				_menubar_menu_open(focused, properties["selected_menu"])
			
			if focused is MenuBar:
				_get_accessible_menubar_name(focused)
				_tts_speak()
				
			_state_updated = true
				
			return false
			
		elif Input.is_action_just_pressed("DOM_item_decrement"):
			var was_opened = _menubar_menu_opened(focused)
			
			_menubar_menu_close_all(focused)
			properties["selected_menu"] -= 1

			if properties["selected_menu"] < 0:
				properties["selected_menu"] = 0
				if properties["menu_opened"] != null:
					properties["menu_opened"] = false
				_update_end_node_position(-1)
			else:
				_end_node_grab_focus()
				
			if was_opened:
				_menubar_menu_open(focused, properties["selected_menu"])
				
			if focused is MenuBar:
				_get_accessible_menubar_name(focused)
				_tts_speak()
				
			_state_updated = true
				
			return false	
			
	return true

static func _menubar_menu_opened(obj):
	var properties = _get_object_data(obj)
	
	if obj is MenuBar:
		if !properties.is_empty():
			if properties["menu_opened"] != null:
				return properties["menu_opened"]
				
	return false
				
static func _menubar_menu_close_all(obj):
	var properties = _get_object_data(obj)
	
	if obj is MenuBar:
		var menu_size = focused.get_menu_count()
		
		for c in range(0, menu_size):
			var popup = obj.get_menu_popup(c)
			
			popup.visible = false
		if !properties.is_empty():	
			if properties["selected_index"] != null:
				properties["selected_index"] = 0
	
static func _menubar_menu_update(obj):
	var properties = _get_object_data(obj)
	if obj is MenuBar:
		if !properties.is_empty():
			if properties["selected_index"] != null:
				var popup = obj.get_menu_popup(properties["selected_menu"])
				popup.set_focused_item(properties["selected_index"])
		
static func _menubar_menu_open(obj, index):
	if obj is MenuBar:
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
		Input.is_action_just_pressed("DOM_right") ||
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
		
		_timer_slider.start(TIMER_SLIDER_SCROLL)
		
		return false
	
	# Only runs if timeout is complete	
	elif _timer_slider.is_stopped():
		var slider_amount = float(focused.max_value - focused.min_value)/float(1.0/focused.step) * MOVEMENT_TIME
		
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
			+ " " + TEXTEDIT_STRINGS[TEXTEDIT_STRING.PASTED])
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
				character = TEXTEDIT_STRINGS[TEXTEDIT_STRING.SPACE]
			elif character == "\t":
				character = TEXTEDIT_STRINGS[TEXTEDIT_STRING.TAB]
				
			# Higher pitched if capital
			if TextFunctions.unicode_is_capital(char_no):
				pitch = 2.0
				
			_add_token(TextFunctions.get_character_name(character))
			_tts_speak(pitch)
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
				_add_token(str(focused.get_caret_line()+1) + " " + TEXTEDIT_STRINGS[TEXTEDIT_STRING.LINE])
				
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
				_add_token(str(focused.get_caret_line()+1) + " " + TEXTEDIT_STRINGS[TEXTEDIT_STRING.LINE])
			
			_tts_speak(pitch)
			_last_caret_line = lines_count
			return false
	
	# If a change is made in the text
	if _last_text != focused.text:
		
		if Input.is_key_pressed(KEY_BACKSPACE):
			var character = "" 
			if last_lines[_last_caret_line].length() > 0:
				if lines.size() > _last_caret_line:
					print(min(caret_position,last_lines.size()-1))
					character = last_lines[_last_caret_line][min(caret_position,last_lines[_last_caret_line].length()-1)]
			else:
				character = TEXTEDIT_STRINGS[TEXTEDIT_STRING.NEWLINE]
			
			_add_token(TextFunctions.get_character_name(character))
				
			_add_token(TEXTEDIT_STRINGS[TEXTEDIT_STRING.DELETED])
			
		elif Input.is_key_pressed(KEY_SPACE):
			_add_token(TEXTEDIT_STRINGS[TEXTEDIT_STRING.SPACE])
		
		elif Input.is_key_pressed(KEY_TAB):
			_add_token(TEXTEDIT_STRINGS[TEXTEDIT_STRING.TAB])
			
		elif (Input.is_key_pressed(KEY_ENTER) ||
				Input.is_key_pressed(KEY_KP_ENTER)):
			_add_token(TEXTEDIT_STRINGS[TEXTEDIT_STRING.ENTER])
			_play_sound("text_newline")
			
			if focused is CodeEdit:
				_add_token(str(focused.get_caret_line()+1) + " " + TEXTEDIT_STRINGS[TEXTEDIT_STRING.LINE])
			
		else:
			if !TextFunctions.special_key_combos():
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
			_add_token(OS.get_keycode_string(c).replace("Kp","").lstrip(" ").rstrip(" "))
		
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
		
		if Input.is_action_just_pressed("DOM_item_decrement"):
			_popup_index-= 1
			
			if _popup_index < 0:
				_popup_visible = false
				popup.visible = false
				_popup_index = 0
				_add_token(MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.CLOSED] % [text] )
			else:
				_play_sound("list_nav", LIST_PITCH_SHIFT)
				changed = true
			
		elif Input.is_action_just_pressed("DOM_item_increment"):
			_popup_index += 1
			
			if _popup_index > focused.item_count-1:
				_popup_visible = false
				popup.visible = false
				_popup_index = 0
				_add_token(MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.CLOSED] % [text] )
			else:
				_play_sound("list_nav")
				changed = true
			
		if changed:
			popup.scroll_to_item(_popup_index)
			popup.set_focused_item(_popup_index)
			
			_add_token(popup.get_item_text(_popup_index))
			_tts_speak()
			
			return false
			
		# If not changed, if you leave the button while open, announce its closing
		if (Input.is_action_just_pressed("DOM_left") ||
			Input.is_action_just_pressed("DOM_right") ||
			Input.is_action_just_pressed("DOM_up") ||
			Input.is_action_just_pressed("DOM_down")):
				_add_token(MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.CLOSED] % [text] )
	
	if Input.is_action_just_pressed("DOM_select"):
		_play_sound("button_down")
		
		if _popup_visible:
			popup.visible = false
			_add_token(STRING_FORMATS[STRING_FORMAT.SELECTED] % [popup.get_item_text(_popup_index)])
			_popup_index = 0
			_add_token(MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.CLOSED] % [text] )
		else:
			focused.emit_signal("about_to_popup")
			focused.show_popup()
			_add_token(popup.get_item_text(_popup_index))
			_add_token(MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.OPENED] % [text] )
			
		_popup_visible = !_popup_visible
		
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
		
		if Input.is_action_just_pressed("DOM_item_decrement"):
			_popup_index-= 1
			
			if _popup_index < 0:
				_popup_visible = false
				popup.visible = false
				_popup_index = 0
				_add_token(MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.CLOSED] % [text] )
			else:
				focused.emit_signal("item_focused",_popup_index)
				_play_sound("list_nav", LIST_PITCH_SHIFT)
				changed = true
			
		elif Input.is_action_just_pressed("DOM_item_increment"):
			_popup_index += 1
			
			if _popup_index > focused.item_count-1:
				_popup_visible = false
				popup.visible = false
				_popup_index = 0
				_add_token(MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.CLOSED] % [text] )
			else:
				focused.emit_signal("item_focused",_popup_index)
				_play_sound("list_nav")
				changed = true
			
		if changed:
			popup.scroll_to_item(_popup_index)
			popup.set_focused_item(_popup_index)
			
			_add_token(popup.get_item_text(_popup_index))
			_tts_speak()
			
			return false
			
		# If not changed, if you leave the button while open, announce its closing
		if (Input.is_action_just_pressed("DOM_left") ||
			Input.is_action_just_pressed("DOM_right") ||
			Input.is_action_just_pressed("DOM_up") ||
			Input.is_action_just_pressed("DOM_down")):
				_add_token(MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.CLOSED] % [text] )
	
	if Input.is_action_just_pressed("DOM_select"):
		_play_sound("button_down")
		
		if _popup_visible:
			popup.visible = false
			_add_token(STRING_FORMATS[STRING_FORMAT.SELECTED] % [popup.get_item_text(_popup_index)])
			_add_token(MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.CLOSED] % [text] )
			focused.emit_signal("item_selected",_popup_index)
		else:
			focused.show_popup()
			_popup_index = max(focused.selected,0)
			_add_token(popup.get_item_text(_popup_index))
			_add_token(MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.OPENED] % [text] )
			
		_popup_visible = !_popup_visible
		
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
					_add_token(TREE_CONTROL_NAMES[TREE_CONTROL.COLLAPSED])
					_play_sound("tree_collapse")
				else:
					_add_token(TREE_CONTROL_NAMES[TREE_CONTROL.UNCOLLAPSED])
					_play_sound("tree_uncollapse")
			else:
				_add_token(TREE_CONTROL_NAMES[TREE_CONTROL.NO_CHILDREN])
				_play_sound("tree_no_children")
		
			_get_accessible_tree_name(focused, false)
		
			_tts_speak()
			_state_updated = true
			return false
			
		if Input.is_action_just_pressed("DOM_item_increment"):
			var next = treeitem.get_next_visible()
			
			if next != null:
				focused.focus_mode = FOCUS_ALL
				focused.grab_focus()
				focused.set_selected(next,0)
				focused.scroll_to_item(next)
				focused.focus_mode = FOCUS_NONE
				_play_sound("list_nav")
				_highlight_tree()
				
			get_accessible_name(focused)
		
			_tts_speak()
			_state_updated = true
			return false
			
		elif Input.is_action_just_pressed("DOM_item_decrement"):
			var next = treeitem.get_prev_visible()
			
			if next != null:
				focused.focus_mode = FOCUS_ALL
				focused.grab_focus()
				focused.set_selected(next,0)
				focused.scroll_to_item(next)
				focused.focus_mode = FOCUS_NONE
				_play_sound("list_nav",LIST_PITCH_SHIFT)
				_highlight_tree()
					
			get_accessible_name(focused)
		
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
static func _find_next_grouping(obj):
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
static func _find_prev_grouping(obj):
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
static func _find_first_obj(arr):
	for c in arr:
		if !(c is Array):
			return c
			
	return null
			
# Returns false if moved in any way.
# This allows for controls to use basic UI commands to navigate too
static func _simple_movement():

	if !_end_node_list.is_empty():
		
		if Input.is_action_just_pressed("ui_down"):
			return 1
		elif Input.is_action_just_pressed("ui_up"):
			return -1
		elif Input.is_action_just_pressed("ui_right"):
			return 1
		elif Input.is_action_just_pressed("ui_left"):
			return -1	

	return 0

# Gets the node position as an array of what indices to take to find it.
static func _get_node_pos(obj):
	var arr = []
		
	_get_node_pos_rec(obj,arr)
				
	return arr
	
static func _get_node_pos_rec(obj, arr=null, search_array=_objects, layer=0):

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
static func _get_node_from_pos(arr):
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
	_grab_obj_focus(_end_node_list[_end_node_position])
	
# This will take the current object and make its tab visible
static func _open_selected_tab(obj):
	var parent = obj.get_parent()
	if parent != null:
		# nearest ancestor tabcontainer is found
		if parent is TabContainer && obj.get_parent().get_children().has(obj):
			parent.current_tab = obj.get_index()
					
		else:
			_open_selected_tab(parent)	
	return null
			
static func _update_end_node_position(movement=0, index=-1):
	
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
static func _grab_obj_focus(obj):
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
			
			# resets state
			_update_draw_state(CONTROL_STATE.FOCUSED)
			
			var old_focus = focused
			
			if focused != null:
				if focused.has_signal("focus_exited"):
					focused.emit_signal("focus_exited")
					focused.focus_mode = FOCUS_NONE
					
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
							
						
						focused.focus_mode = FOCUS_ALL
						focused.grab_focus()
						
				# If it is the tree type, play an entrance sound
				# and set the selected index to the root if none
				# is selected
				if focused is Tree:
					_stop_sound()
					_play_sound("tree_enter")
					if focused.get_selected() == null:
						focused.set_selected(focused.get_root(),0) 
						
			if old_focus != focused:
				# Read the name
				get_accessible_name(focused)
				_tts_speak()
		else:
			obj.call_deferred("grab_focus")
			
		_open_selected_tab(obj)

		
# Releases focus of an object
static func _release_obj_focus(obj):
	if dom_nav_enabled:
		if focused != null:
			focused.focus_mode = FOCUS_NONE
		focused = null
	obj.release_focus()
	
# Checks the current focused object
static func _check_obj_focus(obj):
	if dom_nav_enabled:
		return obj == focused

## TTS management methods

# Speaks the current token state
static func _tts_speak(pitch=1.0,rate=1.0,volume=50):
	if _tokens.is_empty():
		return
	
	var text = ""
	for c in _tokens:
		text += c + " | "
		
	_clear_tokens()
		
	_tts_speak_direct(text, pitch, rate, volume)
	
static func _tts_speak_direct(text, pitch=1.0,rate=1.0,volume=50):
	if !text.is_empty():
		TTS.stop()
		TTS.speak(text, false, TTS.default_lang, pitch, rate, volume)
		
		_timer.start(TIMER_COOLDOWN)
		
static func _is_cooled_down():
	return _timer.is_stopped()
		
## Label reading methods

# Gets the name of a control
static func get_accessible_name(obj):
	
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
static func _get_accessible_label_name(obj):
	var name_val = ""

	if focused is CodeEdit:
		var lines = focused.text.split("\n")
		
		_add_token(TextFunctions.get_character_name(lines[focused.get_caret_line()]))
		_add_token(str(focused.get_caret_line()+1) + " " + TEXTEDIT_STRINGS[TEXTEDIT_STRING.LINE])
	
	else:
		name_val = obj.text
		_add_token(name_val)
		
	if obj.get("alt_text") != null && !obj.alt_text.is_empty():
		name_val = obj.alt_text
		_add_token(name_val)
		
	if verbose:
		if obj.get_class() != name_val:
			if focused is Label:
				_add_token(SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.LABEL])
			else:
				_add_token(obj.get_class()) 
			
# Gets the name for richtext labels
static func _get_accessible_richtext_label_name(obj):
	var name_val = ""
	
	if obj.get("alt_text") != null && !obj.alt_text.is_empty():
		name_val = obj
	else:
		name_val = obj.get_parsed_text()
		
	_add_token(name_val)
			
	if verbose:
		if obj.get_class() != name_val:
			_add_token(SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.LABEL])
			
# Gets the name for buttons
static func _get_accessible_button_name(obj):
	var name_val = ""
	
	if obj is CheckBox:
		if obj.button_pressed:
			_add_token(POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.CHECKED])
		else:
			if verbose:
				_add_token(POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.UNCHECKED])
				
	elif obj is CheckButton:
		if obj.button_pressed:
			_add_token(POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.ON])
		else:
			_add_token(POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.OFF])
				
	if obj.get("alt_text") != null && !obj.alt_text.is_empty():
		name_val = obj.alt_text
		_add_token(name_val)
	else:
		name_val = obj.text
		_add_token(name_val)
			
	if verbose:
		if obj.get_class() != name_val:
			var token = SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.BUTTON]
			if obj is CheckBox:
				token = SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.CHECKBOX]
			elif obj is CheckButton:
				token = SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.SWITCH]
			elif obj is MenuButton:
				token = SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.MENUBUTTON]
			elif obj is OptionButton:
				token = SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.DROPDOWN]
			_add_token(token)
		
# Gets the name for images
static func _get_accessible_image_name(obj):
	var name_val = ""
	
	_add_alt_text(obj)
			
	if verbose:
		if obj.get_class() != name_val:
			_add_token(SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.IMAGE])
		
# Gets the name for progress bars
static func _get_accessible_progress_bar_name(obj):
	var name_val = ""
	
	# reads value
	
	if obj.get("read_fraction") != null:
		if obj.read_fraction:
			var text = STRING_FORMATS[STRING_FORMAT.FRACTION] % [str(obj.value), str(obj.max_value)]
			_add_token(text)
			
		if obj.read_percent:
			var text = STRING_FORMATS[STRING_FORMAT.PERCENT] % [str(floor(100 * obj.value / obj.max_value))]
			_add_token(text)
	else:
		# default if not accessible script
		var text = STRING_FORMATS[STRING_FORMAT.FRACTION] % [str(obj.value), str(obj.max_value)]
		_add_token(text)
	
	_add_alt_text(obj)
	
	if verbose:
		if obj.get_class() != name_val:
			_add_token(SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.PROGRESS_BAR])
			
# Gets the name for spinboxes
static func _get_accessible_spinbox_name(obj):
	var name_val = ""
	
	# reads value
	_add_token(str(obj.value))
	
	_add_alt_text(obj)
	
	if verbose:
		if obj.get_class() != name_val:
			_add_token(SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.SPINBOX])
		
# Gets the name for hslider
static func _get_accessible_hslider_name(obj):
	var name_val = ""
	
	_get_accessible_slider_name(obj)
			
	if verbose:
		if obj.get_class() != name_val:
			_add_token(SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.HSLIDER])
			
# Gets the name for vslider
static func _get_accessible_vslider_name(obj):
	var name_val = ""
	
	_get_accessible_slider_name(obj)
			
	if verbose:
		if obj.get_class() != name_val:
			_add_token(SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.VSLIDER])
		
static func _get_accessible_slider_name(obj):
	# reads value
	
	if obj.get("read_fraction") != null:
		if obj.read_value:
			_add_token(str(obj.value))
			
		if obj.read_fraction:
			var text = STRING_FORMATS[STRING_FORMAT.FRACTION] % [str(obj.value), str(obj.max_value)]
			_add_token(text)
			
		if obj.read_percent:
			var text = STRING_FORMATS[STRING_FORMAT.PERCENT] % [str(floor(100 * obj.value / obj.max_value))]
			_add_token(text)
	else:
		# default if not accessible script
		_add_token(str(obj.value))
	
	_add_alt_text(obj)
		
static func _get_accessible_menubar_name(obj):
	var properties = _get_object_data(obj)
	
	var selected_menu = properties["selected_menu"]
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
			if properties["selected_menu"] != null:
				text = STRING_FORMATS[STRING_FORMAT.FRACTION] % [str(selected_index+1), str(menu_size)]
				_add_token(text)
		
		_add_alt_text(obj)
		
		text = STRING_FORMATS[STRING_FORMAT.SELECTED] % [popup.name]
		_add_token(text)
	else:
		var popup = obj.get_menu_popup(selected_menu)

		text = STRING_FORMATS[STRING_FORMAT.SELECTED] % [popup.name]
		_add_token(text)
		
		# Announce out of 3
		if verbose:
			if properties["selected_menu"] != null:
				text = STRING_FORMATS[STRING_FORMAT.FRACTION] % [str(selected_menu+1), str(sizer)]
				_add_token(text)
		
		_add_alt_text(obj)
	
	if verbose:
		if obj.get_class() != text:
			_add_token(SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.MENUBAR])
	
static func _get_accessible_tabbar_name(obj):

	var selected_menu = obj.current_tab
	var sizer = obj.tab_count
	
	var name_val = obj.get_tab_title(selected_menu)

	var text = STRING_FORMATS[STRING_FORMAT.SELECTED] % [name_val]
	_add_token(text)
	
	# Announce out of 3
	if verbose:
		text = STRING_FORMATS[STRING_FORMAT.FRACTION] % [str(selected_menu+1), str(sizer)]
		_add_token(text)
	
	_add_alt_text(obj)
	
	if verbose:
		if obj.get_class() != name_val:
			_add_token(SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.TABS])
	
# Gets the name for optionbuttons
static func _get_accessible_optionbutton_name(obj):
	var name_val = ""

	if focused.get_selected_id() > -1:
		_add_token(STRING_FORMATS[STRING_FORMAT.SELECTED] % [focused.get_item_text(focused.get_selected_id())])
	else:
		_add_token(STRING_FORMATS[STRING_FORMAT.SELECTED] % [TEXTEDIT_STRINGS[TEXTEDIT_STRING.NONE]])
		
	if obj.get("alt_text") != null && !obj.alt_text.is_empty():
		name_val = obj.alt_text
		_add_token(name_val)
		
	if verbose:
		if obj.get_class() != name_val:
			if focused is Label:
				_add_token(SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.LABEL])
			else:
				_add_token(obj.get_class()) 
	
static func _get_accessible_tree_name(obj, read_collapse=true):
	
	# Read off the currently selected node, if any
	var selected_item = obj.get_selected()
	if selected_item != null:
		_add_token(STRING_FORMATS[STRING_FORMAT.SELECTED] % [selected_item.get_text(0)])
	else:
		_add_token(STRING_FORMATS[STRING_FORMAT.SELECTED] % [TEXTEDIT_STRINGS[TEXTEDIT_STRING.NONE]])

	if selected_item.collapsed:
		if read_collapse:
			_add_token(TREE_CONTROL_NAMES[TREE_CONTROL.COLLAPSED])
	else:
		var child_count = selected_item.get_child_count()
			
		if child_count > 0:
			_add_token(TREE_CONTROL_NAMES[TREE_CONTROL.CHILDREN] % [str(child_count)])
		else:
			_add_token(TREE_CONTROL_NAMES[TREE_CONTROL.NO_CHILDREN])
	
	var name_val = ""
	
	if obj.get("alt_text") != null && !obj.alt_text.is_empty():
		name_val = obj.alt_text
		_add_token(name_val)
	
	if verbose:
		if obj.get_class() != name_val:
				_add_token(obj.get_class()) 
	
# adds alt text	
static func _add_alt_text(obj):
	var name_val = ""
	
	# reads alt text, if any
	if obj.get("alt_text") != null && !obj.alt_text.is_empty():
		name_val = obj.alt_text
		_add_token(name_val)
		
# Clear tokens
static func _clear_tokens():
	_tokens = []
	
# adds token
static func _add_token(token):
	token = token.rstrip(" ").lstrip(" ").rstrip("\n").lstrip("\n")
	if token == ")":
		pass
	
	if(!token.is_empty()):
		_tokens.append(token)
		
## Tree Building Methods

# Searches the tree starting at this node for UI elements to grab
static func _recursive_tree_search(obj,level=0):
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
	var node_type = get_node_type(obj)
	
	if (node_type == NODE_TYPE.INTERACT_NODE) && obj.get("ignore") != true:
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
	if node_type != NODE_TYPE.INTERACT_NODE:
		# If the object has children
		if obj.get_child_count(true) > 0:
			# Go deeper in the recursion
			for c in obj.get_children(true):
				
				# if node is not programmic (unless tabbar
				if !obj.name.contains("@") || obj is TabBar:
					if _recursive_tree_search(c,level+1):
						break
	
	for c in range(0,created):			
		_array_stack.pop_back()
		
	return false

# Function to check if parent is tab container
static func _if_parent_is_TabContainer(obj):
	if obj.get_parent() is TabContainer && obj.get_parent().get_children().has(obj):
		return true
	else:
		return false

# Returns if the container is marked to be used as
# a container in the list.
# Returns 1 = true, 0 = false, -1 no property found
static func _is_marked_container(obj):
	if obj.get("focus_marked_container") != null:
		if obj.focus_marked_container && get_node_type(obj) == NODE_TYPE.CONTAINER:
			return 1
		return 0
			
	return -1

# Function to determine if list item is category or end item
static func get_node_type(obj):
	
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
				return NODE_TYPE.INTERACT_NODE
	
	if (obj is Panel ||
		is_instance_of(obj, Control)):
			return NODE_TYPE.CONTAINER
	
	return NODE_TYPE.IGNORE

# Gets the object list but with no tree structure

static func _get_object_list(list=_objects):
	for c in list:
		if c is Array:
			_get_object_list(c)
		else:
			if get_node_type(NODE_TYPE.INTERACT_NODE):
				_end_node_list.append(c)
				if !_end_node_branches.has(list):
					_end_node_branches.append(list)

# gets the Focus Modes of all child elements

static func _build_focus_mode_list():
	_object_focus_mode = []
	
	_get_focus_mode_rec(dom_root, _object_focus_mode)
	
# recursive function to get focus mode
static func _get_focus_mode_rec(obj, arr):
	for c in obj.get_children(true):
		if c is Control:
			arr.append(c.focus_mode)
			
			if c.get_child_count(true) > 0:
				var new_arr = []
				arr.append(new_arr)
				_get_focus_mode_rec(c, new_arr)

# Sets all the focus objects to have no focus mode
static func _set_focus_off(obj):
	if obj != null:
		for c in obj.get_children(true):
			if c is Control:
				c.focus_mode = Control.FOCUS_NONE
				
				if c.get_child_count(true) > 0:
					_set_focus_off(c)
				
static func _set_focus_on(obj, arr=_object_focus_mode):
	if obj != null && !_object_focus_mode.is_empty():
		var counter = 0
		for c in obj.get_children(true):
			if c is Control:
				c.focus_mode = arr[counter]
				counter += 1
				
				if c.get_child_count(true) > 0:
					_set_focus_on(c,arr[counter])	
					counter+=1

# Highligher Functions

# Updates the draw highlighter
static func _update_draw_highlight():
	if focused is MenuBar:
		_highlight_menubar()
	elif focused is TabBar:
		_highlight_tabbar()
	elif focused is Tree:
		_highlight_tree()
	else:
		_highlight_normal()

# redraws based on menu position
static func _highlight_normal():
	_highlight_box = Rect2(focused.get_global_rect())
	
# redraws based on menubar
static func _highlight_menubar():
	var properties = _get_object_data(focused)
	
	var box = focused.get_global_rect()
	
	var selected = properties["selected_menu"]
	
	var menu_count = focused.get_menu_count()
	
	# This will indicate that accessibility is not configued properly.
	# make sure you add the script
	if selected == null || menu_count < 1:
		_highlight_box = Rect2(box)
	else:

		var h_sep = focused.get_theme_constant("h_separation")

		var length = 0
		var font_size = focused.get_theme_font_size("font_size")
		for c in range(0, selected):
			length += focused.get_theme_font("font").get_string_size(
							focused.get_menu_title(c) + " ",
							HORIZONTAL_ALIGNMENT_LEFT,
							-1,
							font_size).x
			
			length += h_sep*2

		var sizer = focused.get_theme_font("font").get_string_size(
						focused.get_menu_title(selected) + " ",
						HORIZONTAL_ALIGNMENT_LEFT,
						-1,
						font_size)
		
		_highlight_box = Rect2(focused.global_position.x + float(length) * (box.size.x / focused.size.x),
								focused.global_position.y,
								(sizer.x + h_sep) * (box.size.x / focused.size.x),
								(sizer.y + font_size*0.5)  * (box.size.y / focused.size.y))
	
# redraws based on tabbar
static func _highlight_tabbar():
		
	var box = focused.get_global_rect()
		
	var tab_rect = focused.get_tab_rect(focused.current_tab)
		
	_highlight_box = Rect2(
		focused.global_position.x + tab_rect.position.x  * (box.size.x / focused.size.x),
		focused.global_position.y + tab_rect.position.y  * (box.size.y / focused.size.y),
		tab_rect.size.x * (box.size.x / focused.size.x),
		tab_rect.size.y * (box.size.y / focused.size.y)
	)
	
static func _highlight_tree():
	
	
	var v = focused.get_theme_constant("v_separation")
	
	var item = focused.get_selected()
	
	if item == null:
		_highlight_normal()
	else:
		var box = focused.get_global_rect()
		var y_multi = (box.size.y / focused.size.y)
		
		_highlight_box = focused.get_item_area_rect(item)

		_highlight_box.position.y = _highlight_box.position.y * y_multi
		
		_highlight_box.size.x = _highlight_box.size.x * (box.size.x / focused.size.x)
		_highlight_box.size.y = _highlight_box.size.y * y_multi


		_highlight_box.position += focused.global_position
		_highlight_box.position.y -= focused.get_scroll().y  * y_multi
		_highlight_box.size.y += v*2 * y_multi
		
		if focused.global_position.y > _highlight_box.position.y:
			_highlight_box.position.y = focused.global_position.y
			_highlight_box.size.y = 6
			
		if focused.global_position.y + box.size.y < _highlight_box.position.y:
			_highlight_box.position.y = focused.global_position.y + box.size.y
			_highlight_box.size.y = 6
	
# Sound functions

# Note, this sound object only 

# Init functions here, stuff like audio bank can be set.
static func _sound_init(obj):
	obj.add_child(_sfx)

# plays a sound effect
# only from preloaded assets in SFX_LIBRARY
static func _play_sound(name_val, pitch=1.0):
	if sfx_enabled:
		if SFX_LIBRARY.has(name_val):
			_sfx.stream = SFX_LIBRARY[name_val]
			_sfx.pitch_scale = pitch
			_sfx.play()
		
# stops a sound effect
static func _stop_sound():
	_sfx.stop()
	
# Starts playing the sound for the slider
static func _timer_slider_timeout():
	_play_sound("slider")
	
# Menubar Object Tracker functions

# Gets the menubar from object reference
static func _get_object_data(obj):
	if _data_objects.has(obj):
		return _data_objects[obj]
	return {}

# Inserts menubar data into the dictionary
static func _insert_menubar(obj):
	_data_objects[obj] = _create_menubar_object()

# This creates a new initialized menubar info object
static func _create_menubar_object():
	return {
		"selected_menu" : 0,
		"selected_index" : 0,
		"menu_opened" : false
	}
	
# Updates what state to draw the current control in
static func _update_draw_state(state):
	_control_state = state
	
# Initializer Functions

# Gets the DOM state populated
static func init_DOM():
	
	_set_focus_on(dom_root)
	
	_objects = []
	_end_node_list = []
	_end_node_branches = []
	_data_objects = {}
	_array_stack = [_objects]
	
	_recursive_tree_search(dom_root)
	_get_object_list()
	_build_focus_mode_list()
	
static func _prdebug(string):
	if debug:
		print_debug(string)
		
# Inherited functions

# Runs when intialized
static func _do_ready(obj):
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
		if Input.is_action_just_pressed("DOM_read_item"):
			if focused is CodeEdit:
				var lines = focused.text.split("\n")
				
				_add_token(lines[focused.get_caret_line()])
			elif (focused is TextEdit
				|| focused is LineEdit):
				_add_token(focused.text)
			else:
				_add_token(get_accessible_name(focused))
			_tts_speak()
			return true
			
		if event is InputEventMouseButton:
			if focused is Tree:
				if (event.button_index == MOUSE_BUTTON_WHEEL_DOWN
					|| event.button_index == MOUSE_BUTTON_WHEEL_UP):
						_state_updated = true
						
	return false

# Processes the inputs for the DOM object
static func _do_process(delta: float, obj) -> void:
	_process_input(delta)
	
	if focused != null:
		if (_focused_old != focused):
			_update_draw_highlight()
			obj.queue_redraw()
		elif (_focused_rect_old != focused.get_global_rect()):
			_update_draw_highlight()
			obj.queue_redraw()
		elif _state_updated:
			_update_draw_highlight()
			obj.queue_redraw()
	
	_state_updated = false
	
	if focused != null:
		_focused_old = focused
		_focused_rect_old = focused.get_global_rect()
	
## Notification

static func _do_notification(what: int):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		TTS.stop()
		_OS_focused = false
		# If MenuBar is access enabled, closes the menu variables
		if focused is MenuBar:
			if focused.get("selected_index") != null:
				focused.selected_index = 0
				focused.menu_opened = false
				
		# Clears popup variables
		_popup_visible = false
		_popup_index = 0
				
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_OS_focused = true
		
	if what == NOTIFICATION_EXIT_TREE:
		TTS.stop()
