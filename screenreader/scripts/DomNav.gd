extends Control

## Variables

# Whether or not DOM navigation is enabled
var dom_nav_enabled: bool = false

# The object that is referred to as the root of the Dom.
var dom_root: Node = null

# Change this and it will preload a new focus style when focused
# Note, currently as built, if this value is cleared after being used,
# it will not reset currently loaded UI elements.
const DEFAULT_FOCUS_STYLE = preload("res://screenreader/ui/style/focus_end_node.tres")

# This stores the list of objects itself. 
var objects: Array = []

# Only end node objects list
var end_node_list: Array = []

# Keeps track of the array stack
var array_stack: Array = []

# This contains a copy of the old "focus mode" state
# this way you can disable DOM mode and go back
# to the focus mode built by the developer
var object_focus_mode: Array = []

# This is the current object in focus
var focused: Node = null

# The window is currently in focus in the OS
var OS_focused: bool = true

# This is the rect2 of the drawing box for highlighting controls
var highlight_box: Rect2 = Rect2(0,0,0,0)

# Is true if the current control is moving and sliding.
var slider_moving: bool = false

# Is set to the current text object's text after processing.
var last_text: String = ""

# Is set to current caret line for text after processing
var last_caret_line: int = 0

# Is set to the last caret position for text after processing
var last_caret_pos: int = 0

# This prevents bugs with holding down navigation keys with text
var text_wait_to_press: bool = false

# This stores the old value of a slider while sliding
var slider_value: float = 0

# This stores whether or not the slider is actually sliding
var slider_is_sliding: bool = false

# Checks whether a child popup is visible. gets around weird timing bugs.
var popup_visible: bool = false

# Tracks the index of the current popup.
var popup_index: int = 0

# This stores all MenuBars in the DOM with a dictionary
# that represents certain values.
var menubars: Dictionary = {}

# This is used for inserting accessibility tokens
# to be read by the screenreader
var tokens: Array = []

## Movement variables

# Tracks your position navigating end nodes
var end_node_position: int = 0

# Timer object for cooldown
@onready var timer: Timer = Timer.new()

# Timer for slider cooldown
@onready var timer_slider: Timer = Timer.new()

# Timer for slider increment cooldown
@onready var timer_slider_increment: Timer = Timer.new()

# How much time to cooldown
const TIMER_COOLDOWN = 0.3

# How much time to wait before doing slider scrolling
const TIMER_SLIDER_SCROLL = 0.2

# How much the movement time is modified for the slider
const MOVEMENT_TIME = 0.000025

# Options

# Whether or not sound effects are enabled
var sfx_enabled: bool = true

# whether or not navigation wraps around
var navigation_wrap: bool = true

# whether or not subtitles are enabled
var subtitles_enabled: bool = true

# whether or not audio description is enabled
var audio_description_enabled: bool = true

# if true, reads more detailed strings
var verbose: bool = true

# This shows useful debug messages if enabled
var debug: bool = false

# Objects

# Plays sound effects.

var sfx : AudioStreamPlayer = AudioStreamPlayer.new()

# Preloaded library of sfx
const SFX_LIBRARY = {
	"button_down" : preload("res://screenreader/sfx/button_down.wav"),
	"button_up" : preload("res://screenreader/sfx/button_up.wav"),
	"text_enter" : preload("res://screenreader/sfx/text_enter.wav"),
	"text_newline" : preload("res://screenreader/sfx/text_newline.wav"),
	"tab_nav" : preload("res://screenreader/sfx/tab_nav.wav"),
	"slider" : preload("res://screenreader/sfx/slider_change.wav"),
	"slider_move" : preload("res://screenreader/sfx/slider_move.wav")
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

# This is used for highlighting UI elements
var control_state: int = CONTROL_STATE.FOCUSED
var focused_box: Rect2 = Rect2(0,0,0,0)
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

const TEXTEDIT_CHARACTER_NAMES = {
	" " : "Space",
	"." : "Period",
	"," : "Comma",
	";" : "Semicolon",
	"/" : "Forward Slash",
	"\\" : "Backslash",
	"+" : "Plus",
	"-" : "Dash",
	"*" : "Asterisk",
	"=" : "Equals Sign",
	"!" : "Exclaimation Point",
	"?" : "Question Mark",
	"@" : "At Symbol",
	"#" : "Pound Symbol",
	"$" : "Dollar Sign",
	"%" : "Percent",
	"^" : "Carat",
	"&" : "Ampersand",
	"(" : "Left Parentheses",
	")" : "Right Parentheses",
	"[" : "Left Bracket",
	"]" : "Right Bracket",
	"{" : "Left Curly Bracket",
	"}" : "Right Curly Bracket",
	"|" : "Pipe Symbol",
	"'" : "Apostrophe",
	"\"" : "Quotation Mark",
	":" : "Colon",
	">" : "Greater Than Symbol",
	"<" : "Less Than Symbol",
	"_" : "Underscore",
	"~" : "Tilde",
	"\t" : "Tab"
}

## Other Enums

# this determines how nodes will be treated and assigned
enum NODE_TYPE {
	CONTAINER,
	INTERACT_NODE,
	IGNORE
}

## Notification

func _notification(what: int):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		TTS.stop()
		OS_focused = false
		# If MenuBar is access enabled, closes the menu variables
		if focused is MenuBar:
			if focused.get("selected_index") != null:
				focused.selected_index = 0
				focused.menu_opened = false
				
		# Clears popup variables
		popup_visible = false
		popup_index = 0
				
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		OS_focused = true
		
	if what == NOTIFICATION_EXIT_TREE:
		TTS.stop()

## Control methods

# Sets the dom root node.
func set_dom_root(obj):
	dom_root = obj
	init_DOM()

func enable_dom(value=true):
	dom_nav_enabled = value
	
	# disables godot focus, uses custom UI built
	# in this class
	if dom_nav_enabled:
		set_focus_off(dom_root)
		# grabs the first active end node
		end_node_grab_focus()
	
	# enables dom
	else:
		set_focus_on(dom_root)

## Finder methods

func find_object_type(type, max=1):
	var counter = 0
	for c in end_node_list:
		if get_node_type(c) == type && counter >= max:
			return c
		counter+=1
	return null

## Processing/navigation functions

# Processes interacting with inputs
func process_input(delta):

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
			default_move = process_video_controls()
		elif focused is MenuBar:
			default_move = process_menubar_controls()
		elif focused is TabBar:
			default_move = process_tabbar_controls()
		elif focused is MenuButton:
			default_move = process_menu_button_controls()
		elif focused is OptionButton:
			default_move = process_option_button_controls()
		elif (focused is Button ||
				focused is LinkButton ||
				focused is TextureButton):
				default_move = process_button_controls()
		elif (focused is HSlider ||
				focused is VSlider ||
				focused is SpinBox):
			default_move = process_slider_controls()
		elif (focused is LineEdit ||
				focused is TextEdit):
			default_move = process_text_controls()
		
	# Processes parent tabbar
	
	if do_screenreader_navigation:

		if default_move:
			default_move = process_parent_tabbar()
			
		# If able, do the normal tabbing dom movement
		if default_move:
			default_move = simple_movement()
			
	# If no movement, process information keys
	if default_move:
		default_move = process_info_keys()
	
# Processes keys for getting information
# like rereading the current element
func process_info_keys():
	if Input.is_action_just_pressed("DOM_read_item"):
		get_accessible_name(focused)
		tts_speak()
		return false
	
	if Input.is_action_just_pressed("DOM_stop_talk"):
		TTS.stop()
		
	return true

# Processes if parent is TabBar
func process_parent_tabbar():
			
	var cur_node_pos = get_node_pos(focused)
	var cur_node_size = cur_node_pos.size()-1
			
	var new_node = find_parent_tabbar(focused)
		
	if new_node is TabBar:
		
		# If moving backward, go back to the tab menu.
		if (Input.is_action_just_pressed("DOM_left")
			|| Input.is_action_just_pressed("DOM_up")
			|| Input.is_action_just_pressed("DOM_prev")):
				
				# if the first item in the list
				if (cur_node_pos[cur_node_size] == 0):
					update_end_node_position(0, end_node_list.find(new_node))
					return false
					
		# If moving foward, go to what is after the last tabs.
		elif (Input.is_action_just_pressed("DOM_right")
			|| Input.is_action_just_pressed("DOM_down")
			|| Input.is_action_just_pressed("DOM_next")):
				var copyarray = cur_node_pos.duplicate(false)
				copyarray[copyarray.size()-1] += 1
				
				if get_node_from_pos(copyarray) == null:
					# find the next valid node
					var newer_node = null
					
					for c in range(end_node_position, end_node_list.size()):
						var node_pos = get_node_pos(end_node_list[c])
						
						var new_pos = []
						
						for d in range(0,node_pos.size()-2):
							new_pos.append(node_pos[d])
						
						var size = new_pos.size()-1
					
						if size > 0:
							new_pos[size] -= 1
							if new_pos[size] < 0:
								new_pos[size] = 0
					
						new_node = get_node_from_pos(new_pos)
						
						if !(new_node is TabBar) && !(new_node is Array):
							newer_node = end_node_list[c]
					
							update_end_node_position(0, end_node_list.find(newer_node))
							return false
			
	return true

func find_parent_tabbar(obj):
	var obj_pos = get_node_pos(obj)
	if !obj_pos.is_empty():
		var test_obj = null
		var new_arr = obj_pos.duplicate()
		
		if !new_arr.is_empty():
			new_arr = new_arr.slice(0, new_arr.size()-1)
			
			while !new_arr.is_empty() && test_obj == null:
				# tab bar will always be the one before the caller
				new_arr[new_arr.size()-1] -= 1
				if new_arr[new_arr.size()-1] < 0:
					new_arr[new_arr.size()-1] = 0
					
				test_obj = get_node_from_pos(new_arr)
				
				if !(test_obj is TabBar):
					test_obj = null
					
				new_arr = new_arr.slice(0, new_arr.size()-1)
					
			return test_obj
		
	return null

# Button controls
func process_button_controls():
	var activated = true
	var toggle_old = focused.button_pressed
	var old_text = focused.text
	
	var pressed = false
	
	# Allows you to press buttons normally
	if Input.is_action_just_pressed("ui_accept"):
		focused.emit_signal("button_down")
		play_sound("button_down")
		update_draw_state(CONTROL_STATE.PRESSED)
		activated = false
	elif Input.is_action_just_released("ui_accept"):
		focused.emit_signal("button_up")
		play_sound("button_up")
		update_draw_state(CONTROL_STATE.FOCUSED)
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
				add_token(POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.CHECKED])
			else:
				add_token(POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.UNCHECKED])
					
		elif focused is CheckButton:
			if focused.button_pressed:
				add_token(POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.ON])
			else:
				add_token(POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.OFF])
		else:
			var alt_text = focused.get("alt_text")
			if alt_text == null:
				add_token(old_text)
			else:
				add_token(alt_text)
			
		tts_speak()
	
	return activated 

# Video controls
# returns false if movement is registered
func process_video_controls():
	
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
		
	tts_speak_direct(read_text)
	
	if !read_text.is_empty():
		return false
				
	return true

# Following are menubar control items

# Does the menubar controls
func process_menubar_controls():
	var menu_size = focused.get_menu_count()
	var properties = get_menubar_data(focused)
	var menu_pos = 0
	
	if !properties.is_empty():
		menu_pos = properties["selected_menu"]
	
	if menu_pos != null:
		if Input.is_action_just_pressed("DOM_select"):
			# If menu is not opened, open it.
			if !menubar_menu_opened(focused):
				# opens the currently selected menu
				menubar_menu_close_all(focused)
				menubar_menu_open(focused, menu_pos)
				if properties["menu_opened"] != null:
					properties["menu_opened"] = true
					
				var text = MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.OPENED] % [focused.get_menu_title(menu_pos)]
				add_token(text)
				
				var popup = focused.get_menu_popup(menu_pos)
				var selected_pos = properties["selected_index"]
				
				# Which menu item is selected
				text = STRING_FORMATS[STRING_FORMAT.SELECTED] % popup.get_item_text(selected_pos)
				add_token(text)
				
				tts_speak()
				return false
			else:
				# If menu is opened, press the button
				var popup = focused.get_menu_popup(menu_pos)
				var selected_pos = properties["selected_index"]
				
				var text = MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.CLOSED] % [focused.get_menu_title(menu_pos)]
				add_token(text)
				
				tts_speak()
				
				# close menu
				return menubar_close_menu(properties)
				
		elif Input.is_action_just_pressed("DOM_cancel"):
			var val = menubar_close_menu(properties)
			
			var text = MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.CLOSED]
			add_token(text)
			
			tts_speak()
			
			return val
		
		# If the menu is open, don't navigate, but do read names
		if menubar_menu_opened(focused):
			if Input.is_action_just_pressed("ui_up"):
				menubar_read_selected_item(properties)
			if Input.is_action_just_pressed("ui_down"):
				menubar_read_selected_item(properties)
		
	# Moves around the top menu
	var move = menubar_nav_menus(properties)
	
	if !move:
		return false
		
	# Disables normal navigation if the menu is opened	
	if menubar_menu_opened(focused):
		return false
			
	return true

func menubar_close_menu(properties):
	# Closes menu if open
	if menubar_menu_opened(focused):
		menubar_menu_close_all(focused)
		if properties["menu_opened"] != null:
			properties["menu_opened"] = false
			
		return false

func menubar_read_selected_item(properties):
	var menu_size = focused.get_menu_count()
	var menu_pos = properties["selected_menu"]
	
	var popup = focused.get_menu_popup(menu_pos)
	var selected_pos = popup.get_focused_item()
	
	var text = popup.get_item_text(selected_pos)
	add_token(text)
	
	# Check if menubar is checked and is radio/checkbox
	if popup.is_item_checkable(selected_pos):
		
		# Checked/unchecked token
		if popup.is_item_checked(selected_pos):
			text = POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.CHECKED]
		else:
			text = POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.UNCHECKED]
		add_token(text)
		
		# Adds if item is checkbox or radio button
		# verbose mode only
		if verbose:
			if popup.is_item_radio_checkable(selected_pos):
				text = POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.RADIOBUTTON]
			else:
				text = POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.CHECKBOX]
				
			add_token(text)
			
	
	tts_speak()

func menubar_nav_menus(properties):
	if !properties.is_empty():
		if Input.is_action_just_pressed("DOM_item_increment"):
			var was_opened = menubar_menu_opened(focused)
			
			var size = focused.get_menu_count()
			menubar_menu_close_all(focused)

			properties["selected_menu"] += 1

			if properties["selected_menu"] >= size:
				properties["selected_menu"] = size-1
				if properties["menu_opened"] != null:
					properties["menu_opened"] = false
				update_end_node_position(1)
			else:
				end_node_grab_focus()
				
			if was_opened:
				menubar_menu_open(focused, properties["selected_menu"])
			
			if focused is MenuBar:
				get_accessible_menubar_name(focused)
				tts_speak()
				
			return false
			
		elif Input.is_action_just_pressed("DOM_item_decrement"):
			var was_opened = menubar_menu_opened(focused)
			
			menubar_menu_close_all(focused)
			properties["selected_menu"] -= 1

			if properties["selected_menu"] < 0:
				properties["selected_menu"] = 0
				if properties["menu_opened"] != null:
					focused.menu_opened = false
				update_end_node_position(-1)
			else:
				end_node_grab_focus()
				
			if was_opened:
				menubar_menu_open(focused, properties["selected_menu"])
				
			if focused is MenuBar:
				get_accessible_menubar_name(focused)
				tts_speak()
				
			return false	
			
	return true

func menubar_menu_opened(obj):
	var properties = get_menubar_data(obj)
	
	if obj is MenuBar:
		if !properties.is_empty():
			if properties["menu_opened"] != null:
				return properties["menu_opened"]
				
	return false
				
func menubar_menu_close_all(obj):
	var properties = get_menubar_data(obj)
	
	if obj is MenuBar:
		var menu_size = focused.get_menu_count()
		
		for c in range(0, menu_size):
			var popup = obj.get_menu_popup(c)
			
			popup.visible = false
		if !properties.is_empty():	
			if properties["selected_index"] != null:
				properties["selected_index"] = 0
	
func menubar_menu_update(obj):
	var properties = get_menubar_data(obj)
	if obj is MenuBar:
		if !properties.is_empty():
			if properties["selected_index"] != null:
				var popup = obj.get_menu_popup(properties["selected_menu"])
				popup.set_focused_item(properties["selected_index"])
		
func menubar_menu_open(obj, index):
	if obj is MenuBar:
		var popup = obj.get_menu_popup(index)
		
		popup.visible = true
		
		# Sets position for popup
		
		var h_sep = focused.get_theme_constant("h_separation")

		var len = 0
		var font_size = focused.get_theme_font_size("font_size")
		for c in range(0, index):
			len += focused.get_theme_font("font").get_string_size(
							focused.get_menu_title(c) + " ",
							HORIZONTAL_ALIGNMENT_LEFT,
							-1,
							font_size).x
			
			len += h_sep*2

		var sizer = focused.get_theme_font("font").get_string_size(
						focused.get_menu_title(index) + " ",
						HORIZONTAL_ALIGNMENT_LEFT,
						-1,
						font_size)
		
		
		popup.position = Vector2(focused.global_position.x + float(len),
						focused.global_position.y + font_size * 1.5)
		
		menubar_menu_update(obj)

# Following are tabbar movement funcionts

func process_tabbar_controls():
	var tab_val = focused.current_tab
	var tab_size = focused.tab_count
	
	if Input.is_action_just_pressed("DOM_item_increment"):
		tab_val += 1
		
		if tab_val >= tab_size:
			tab_val = tab_size-1
			focused.current_tab = tab_val
		else:
			focused.current_tab = tab_val
			
		end_node_grab_focus()
		
		if focused is TabBar:
			play_sound("tab_nav", 0.75 + (focused.current_tab / tab_size)*0.5)
		
			get_accessible_tabbar_name(focused)
			tts_speak()
		
			focused.emit_signal("tab_changed", focused.current_tab)
			focused.emit_signal("tab_selected", focused.current_tab)
		
		return false
		
	elif Input.is_action_just_pressed("DOM_item_decrement"):
		tab_val -= 1
		
		if tab_val < 0:
			tab_val = 0
			focused.current_tab = tab_val
			
		else:
			focused.current_tab = tab_val
			
		end_node_grab_focus()
		
		if focused is TabBar:
			play_sound("tab_nav", 0.75 + (focused.current_tab / tab_size)*0.5)
		
			get_accessible_tabbar_name(focused)
			tts_speak()
		
			focused.emit_signal("tab_changed", focused.current_tab)
			focused.emit_signal("tab_selected", focused.current_tab)
		
		return false
		
	# If moving to the next element, select the first
	# element in the current panel
	elif (Input.is_action_just_pressed("DOM_next") ||
		Input.is_action_just_pressed("DOM_right") ||
		Input.is_action_just_pressed("DOM_down")):
		
		var parent = focused.get_parent().get_child(focused.current_tab)
		
		# find the first node with this ancestor in the object list
		for c in range(0,end_node_list.size()):
			if parent.is_ancestor_of(end_node_list[c]):
				update_end_node_position(0, c)
				return false
	
	return true

# Processes slider controls
func process_slider_controls():
	
	sfx.pitch_scale = 0.75 + 0.5 * ((focused.value - focused.min_value) / (focused.max_value - focused.min_value))
	
	# If released, stops slider mode.
	if (!(Input.is_action_pressed("DOM_item_decrement")
		|| Input.is_action_pressed("DOM_item_increment"))
		&& (Input.is_action_just_released("DOM_item_decrement")
		|| Input.is_action_just_released("DOM_item_increment"))):
		slider_moving = false
		stop_sound()
		
		# Adds default name tokens if verbose
		# Only reads if timer is stopped
		if verbose:
			if focused is HSlider:
				get_accessible_hslider_name(focused)
			elif focused is VSlider:
				get_accessible_vslider_name(focused)
			elif focused is SpinBox:
				get_accessible_spinbox_name(focused)
		else:
			add_token(str(focused.value))
		
		if (focused is HSlider ||
			focused is VSlider):
				focused.emit_signal("drag_ended", slider_value != focused.value)
		
		tts_speak()
		
		timer_slider.stop()
		
		return false
	
	# If pressed down, enters slider mode.
	elif (Input.is_action_just_pressed("DOM_item_decrement")
		|| Input.is_action_just_pressed("DOM_item_increment")):
		slider_moving = true
		slider_value = focused.value
		TTS.stop()
		
		# updates slider position
		if Input.is_action_just_pressed("DOM_item_increment"):
			focused.value += focused.step
			focused.emit_signal("value_changed", focused.value)
		elif Input.is_action_just_pressed("DOM_item_decrement"):
			focused.value -= focused.step
			focused.emit_signal("value_changed", focused.value)
		
		play_sound("slider_move")
		
		timer_slider.start(TIMER_SLIDER_SCROLL)
		
		return false
	
	# Only runs if timeout is complete	
	elif timer_slider.is_stopped():
		var slider_amount = float(focused.max_value - focused.min_value)/float(1.0/focused.step) * MOVEMENT_TIME
		
		var cooldown = focused.get("cooldown_time")
		
		if cooldown != null && cooldown > 0:
			slider_amount = cooldown
			
		if (Input.is_action_pressed("DOM_item_increment")):
			if !slider_is_sliding:
				slider_is_sliding = true
				if (focused is HSlider ||
					focused is VSlider):
						focused.emit_signal("drag_started")
			
			if timer_slider_increment.is_stopped():
				focused.value += focused.step
				timer_slider_increment.start(slider_amount)
				focused.emit_signal("value_changed", focused.value)
			return false
			
		elif (Input.is_action_pressed("DOM_item_decrement")):
			if !slider_is_sliding:
				slider_is_sliding = true
				if (focused is HSlider ||
					focused is VSlider):
						focused.emit_signal("drag_started")
			
			if timer_slider_increment.is_stopped():
				focused.value -= focused.step
				timer_slider_increment.start(slider_amount)
				focused.emit_signal("value_changed", focused.value)
			return false
		
	return true

# checks if unicode is a capital letter
func unicode_is_capital(unicode):
	return unicode >= 65 && unicode <= 90

# These are special key combos that are ignored for some purposes
func special_key_combos():
	# paste
	if (KeyFrame.pressed_keys.has(KEY_CTRL)
		&& KeyFrame.pressed_keys.has(KEY_V)):
		return true
	
	return false
	
# Returns the string of certain characters
func get_character_name(char):
	if focused is CodeEdit:
		for c in TEXTEDIT_CHARACTER_NAMES:
			if c != " ":
				char = char.replace(c, " " + TEXTEDIT_CHARACTER_NAMES[c] + " ")
	
	if TEXTEDIT_CHARACTER_NAMES.has(char):
		return TEXTEDIT_CHARACTER_NAMES[char]
	
	return char

# Does the text edit controls
func process_text_controls():
	clear_tokens()

	if (Input.is_action_just_pressed("ui_up") ||
		Input.is_action_just_released("ui_up") ||
		Input.is_action_just_pressed("ui_down") ||
		Input.is_action_just_released("ui_down")):
			text_wait_to_press = true

	var lines_count = 0
	var caret_position = focused.get_caret_column();
	var lines = focused.text.split("\n")
	var last_lines = last_text.split("\n")
	
	var pitch = 1.0
	
	if focused is TextEdit:
		lines_count = focused.get_caret_line()
	
	# pasted clipboard contents
	if (KeyFrame.key_pressed() && 
		KeyFrame.pressed_keys.has(KEY_CTRL)
		&& KeyFrame.pressed_keys.has(KEY_V)):
		add_token(DisplayServer.clipboard_get()
			+ " " + TEXTEDIT_STRINGS[TEXTEDIT_STRING.PASTED])
		tts_speak()
		return false
	
	# Ignores movement inputs if navigating string with left/right
	if (Input.is_action_pressed("ui_left")
		|| Input.is_action_just_pressed("ui_left")
		|| Input.is_action_pressed("ui_right")
		|| Input.is_action_just_pressed("ui_right")):
			
			var char = ""
			var char_no = 0
			if !lines[lines_count].is_empty():
				if caret_position >= lines[lines_count].length():
					char = lines[lines_count][lines[lines_count].length()-1]
				else:
					char = lines[lines_count][caret_position]
				
				char_no = char.unicode_at(0)
				
			if char == " ":
				char = TEXTEDIT_STRINGS[TEXTEDIT_STRING.SPACE]
			elif char == "\t":
				char = TEXTEDIT_STRINGS[TEXTEDIT_STRING.TAB]
				
			# Higher pitched if capital
			if unicode_is_capital(char_no):
				pitch = 2.0
				
			add_token(get_character_name(char))
			tts_speak(pitch)
			return false
			
	if focused is TextEdit:
		if text_wait_to_press && (Input.is_action_pressed("ui_up")
			|| Input.is_action_just_pressed("ui_up")):
			# Read the current line
			var char = lines[lines_count]
			var char_no = -1
			if char.length() == 1:
				char_no = char.unicode_at(0)
				
			char = get_character_name(char)
				
			# Higher pitched if capital
			if unicode_is_capital(char_no):
				pitch = 2.0
				
			if last_caret_line == 0:
				return true
				
			add_token(get_character_name(char))
				
			if focused is CodeEdit:
				add_token(str(focused.get_caret_line()+1) + " " + TEXTEDIT_STRINGS[TEXTEDIT_STRING.LINE])
				
			tts_speak(pitch)
			last_caret_line = lines_count
			return false
			
		elif text_wait_to_press && (Input.is_action_pressed("ui_down")
			|| Input.is_action_just_pressed("ui_down")):
			var char = lines[lines_count]
			var char_no = -1
			if char.length() == 1:
				char_no = char.unicode_at(0)
				
			char = get_character_name(char)
				
			# Higher pitched if capital
			if char.length() > 1 && char_no > -1 && unicode_is_capital(char_no):
				pitch = 2.0
				
			if last_caret_line > lines_count-1:
				return true
				
			# Read the current line
			add_token(get_character_name(char))
			
			if focused is CodeEdit:
				add_token(str(focused.get_caret_line()+1) + " " + TEXTEDIT_STRINGS[TEXTEDIT_STRING.LINE])
			
			tts_speak(pitch)
			last_caret_line = lines_count
			return false
	
	# If a change is made in the text
	if last_text != focused.text:
		
		if Input.is_key_pressed(KEY_BACKSPACE):
			var char = "" 
			if last_lines[last_caret_line].length() > 0:
				if lines.size() > last_caret_line:
					print(min(caret_position,last_lines.size()-1))
					char = last_lines[last_caret_line][min(caret_position,last_lines[last_caret_line].length()-1)]
			else:
				char = TEXTEDIT_STRINGS[TEXTEDIT_STRING.NEWLINE]
			
			add_token(get_character_name(char))
				
			add_token(TEXTEDIT_STRINGS[TEXTEDIT_STRING.DELETED])
			
		elif Input.is_key_pressed(KEY_SPACE):
			add_token(TEXTEDIT_STRINGS[TEXTEDIT_STRING.SPACE])
		
		elif Input.is_key_pressed(KEY_TAB):
			add_token(TEXTEDIT_STRINGS[TEXTEDIT_STRING.TAB])
			
		elif (Input.is_key_pressed(KEY_ENTER) ||
				Input.is_key_pressed(KEY_KP_ENTER)):
			add_token(TEXTEDIT_STRINGS[TEXTEDIT_STRING.ENTER])
			play_sound("text_newline")
			
			if focused is CodeEdit:
				add_token(str(focused.get_caret_line()+1) + " " + TEXTEDIT_STRINGS[TEXTEDIT_STRING.LINE])
			
		else:
			if !special_key_combos():
				var char = lines[lines_count][max(caret_position-1,0)]
				var char_no = char.unicode_at(0)
					
				# Higher pitched if capital
				if unicode_is_capital(char_no):
					pitch = 2.0
		
				add_token(get_character_name(char))
				
		tts_speak(pitch)
		
		last_text = focused.text
		last_caret_line = lines_count
		last_caret_pos = caret_position
		
		return false
		
		
	elif text_wait_to_press && !KeyFrame.pressed_keys.is_empty() && KeyFrame.key_pressed():
		clear_tokens()
		
		for c in KeyFrame.pressed_keys:
			add_token(OS.get_keycode_string(c).replace("Kp","").lstrip(" ").rstrip(" "))
		
		tts_speak()
			
	
	return true

func process_menu_button_controls():
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

	if popup_visible:
		var changed = false
		
		if Input.is_action_just_pressed("DOM_item_decrement"):
			popup_index-= 1
			
			if popup_index < 0:
				popup_visible = false
				popup.visible = false
				popup_index = 0
				add_token(MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.CLOSED] % [text] )
			else:
				changed = true
			
		elif Input.is_action_just_pressed("DOM_item_increment"):
			popup_index += 1
			
			if popup_index > focused.item_count-1:
				popup_visible = false
				popup.visible = false
				popup_index = 0
				add_token(MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.CLOSED] % [text] )
			else:
				changed = true
			
		if changed:
			popup.scroll_to_item(popup_index)
			popup.set_focused_item(popup_index)
			
			add_token(popup.get_item_text(popup_index))
			tts_speak()
			
			return false
			
		# If not changed, if you leave the button while open, announce its closing
		if (Input.is_action_just_pressed("DOM_left") ||
			Input.is_action_just_pressed("DOM_right") ||
			Input.is_action_just_pressed("DOM_up") ||
			Input.is_action_just_pressed("DOM_down")):
				add_token(MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.CLOSED] % [text] )
	
	if Input.is_action_just_pressed("DOM_select"):
		play_sound("button_down")
		
		if popup_visible:
			popup.visible = false
			popup_index = 0
			add_token(MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.CLOSED] % [text] )
		else:
			focused.emit_signal("about_to_popup")
			focused.show_popup()
			add_token(popup.get_item_text(popup_index))
			add_token(MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.OPENED] % [text] )
			
		popup_visible = !popup_visible
		
		tts_speak()
		return false

	if Input.is_action_just_released("DOM_select"):
		play_sound("button_up")
		
	return true

func process_option_button_controls():
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

	if popup_visible:
		var changed = false
		
		if Input.is_action_just_pressed("DOM_item_decrement"):
			popup_index-= 1
			
			if popup_index < 0:
				popup_visible = false
				popup.visible = false
				popup_index = 0
				add_token(MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.CLOSED] % [text] )
			else:
				focused.emit_signal("item_focused",popup_index)
				changed = true
			
		elif Input.is_action_just_pressed("DOM_item_increment"):
			popup_index += 1
			
			if popup_index > focused.item_count-1:
				popup_visible = false
				popup.visible = false
				popup_index = 0
				add_token(MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.CLOSED] % [text] )
			else:
				focused.emit_signal("item_focused",popup_index)
				changed = true
			
		if changed:
			popup.scroll_to_item(popup_index)
			popup.set_focused_item(popup_index)
			
			add_token(popup.get_item_text(popup_index))
			tts_speak()
			
			return false
			
		# If not changed, if you leave the button while open, announce its closing
		if (Input.is_action_just_pressed("DOM_left") ||
			Input.is_action_just_pressed("DOM_right") ||
			Input.is_action_just_pressed("DOM_up") ||
			Input.is_action_just_pressed("DOM_down")):
				add_token(MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.CLOSED] % [text] )
	
	if Input.is_action_just_pressed("DOM_select"):
		play_sound("button_down")
		
		if popup_visible:
			popup.visible = false
			popup_index = popup.get_focused_item()
			add_token(MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.CLOSED] % [text] )
			focused.emit_signal("item_selected",popup_index)
		else:
			focused.show_popup()
			
			add_token(popup.get_item_text(popup_index))
			add_token(MENUBAR_NAVIGATION_STRINGS[MENUBAR_NAVIGATION.OPENED] % [text] )
			
		popup_visible = !popup_visible
		
		tts_speak()
		return false

	if Input.is_action_just_released("DOM_select"):
		play_sound("button_up")
		
	return true

# Returns false if moved in any way.
# This allows for controls to use basic UI commands to navigate too
func simple_movement():

	if !end_node_list.is_empty():
		
		var node_pos = -1
		
		# Update nodepos based on navigation point in tree
		
		var dom_movement = Vector2.ZERO
		
		if Input.is_action_just_pressed("ui_down"):
			update_end_node_position(1)
			return false
		elif Input.is_action_just_pressed("ui_up"):
			update_end_node_position(-1)
			return false
		elif Input.is_action_just_pressed("ui_right"):
			update_end_node_position(1)
			return false
		elif Input.is_action_just_pressed("ui_left"):
			update_end_node_position(-1)
			return false	
		elif Input.is_action_just_pressed("ui_focus_prev"):
			update_end_node_position(-1)
			return false
		elif Input.is_action_just_pressed("ui_focus_next"):
			update_end_node_position(1)
			return false

	return true

# Gets the node position as an array of what indices to take to find it.
func get_node_pos(obj):
	var arr = []
		
	get_node_pos_rec(obj,arr)
				
	return arr
	
func get_node_pos_rec(obj, arr=null, search_array=objects, layer=0):

	arr.append(0)

	for c in search_array:
		if c is Array:
			if get_node_pos_rec(obj, arr, c, layer+1):
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
func get_node_from_pos(arr):
	
	var node = objects
	
	if arr.is_empty():
		return null
	
	for c in arr:
		if node.size() > c:
			node = node[c]
		else:
			return null
		
	return node
	
# The selected end node grabs focus.		
func end_node_grab_focus():
	grab_obj_focus(end_node_list[end_node_position])
	
# This will take the current object and make its tab visible
func open_selected_tab(obj):
	var parent = obj.get_parent()
	if parent != null:
		# nearest ancestor tabcontainer is found
		if parent is TabContainer && obj.get_parent().get_children().has(obj):
			parent.current_tab = obj.get_index()
					
		else:
			open_selected_tab(parent)	
	return null
			
func update_end_node_position(movement=0, index=-1):
	var old_node_pos = end_node_position
	
	# if an exact index is defined, use that
	if index > -1:
		end_node_position = index
	else:
		end_node_position+=movement
		
	# Correct navigation position to be within the array
	# If navigation wraps
	if navigation_wrap:
		if end_node_position >= end_node_list.size():
			end_node_position = 0
		elif end_node_position < 0:
			end_node_position = end_node_list.size()-1

	else:
		if end_node_position >= end_node_list.size():
			end_node_position = end_node_list.size()-1
		elif end_node_position < 0:
			end_node_position = 0

	# TabBar exception. 
	# If entering a tab bar, do not change the page.
	# Jump to the first item on the current page.
	var test_node = end_node_list[end_node_position]
	var tab_bar = find_parent_tabbar(test_node)
	if !(focused is TabBar) && find_parent_tabbar(focused) == null && tab_bar != null:
		var parent = tab_bar.get_parent().get_child(tab_bar.current_tab)
		
		# find the first node with this ancestor in the object list
		for c in range(0,end_node_list.size()):
			if parent.is_ancestor_of(end_node_list[c]):
				end_node_position = c

	end_node_grab_focus()
	
	prdebug("Focus position: %s" % str(get_node_pos(focused)))

## Focus methods

# Grabs focus of an object
func grab_obj_focus(obj):
	if obj != null:
		if dom_nav_enabled:
			
			# Release any sliders
			slider_moving = false
			sfx.pitch_scale = 1.0
			timer_slider.stop()
			slider_value = 0
			slider_is_sliding = false
			
			# Clears text
			last_text = ""
			last_caret_line = 0
			text_wait_to_press = false
			
			# Clears a popup if any exists
			popup_visible = false
			popup_index = 0
			if focused != null:
				if focused.has_method("get_popup"):
					focused.get_popup().visible = false
				
			
			
			# resets state
			update_draw_state(CONTROL_STATE.FOCUSED)
			
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
						stop_sound()
						play_sound("text_enter")
						
						last_text = focused.text
						# Reset caret position
						focused.set_caret_column(0)
						if focused is TextEdit:
							focused.set_caret_line(0)
							
						
						focused.focus_mode = FOCUS_ALL
						focused.grab_focus()
						
			if old_focus != focused:
				# Read the name
				get_accessible_name(focused)
				tts_speak()
		else:
			obj.call_deferred("grab_focus")
			
		open_selected_tab(obj)
		
		# Redraw control highlighter
		await get_tree().create_timer(0.01).timeout
		
		if focused is MenuBar:
			highlight_menubar()
		elif focused is TabBar:
			highlight_tabbar()
		else:
			highlight_normal()
		
# Releases focus of an object
func release_obj_focus(obj):
	if dom_nav_enabled:
		if focused != null:
			focused.focus
			focused.focus_mode = FOCUS_NONE
		focused = null
	obj.release_focus()
	
# Checks the current focused object
func check_obj_focus(obj):
	if dom_nav_enabled:
		return obj == focused
	else:
		return obj == get_viewport().gui_get_focus_owner()

## TTS management methods

# Speaks the current token state
func tts_speak(pitch=1.0,rate=1.0,volume=50):
	if tokens.is_empty():
		return
	
	var text = ""
	for c in tokens:
		text += c + " | "
		
	clear_tokens()
		
	tts_speak_direct(text, pitch, rate, volume)
	
func tts_speak_direct(text, pitch=1.0,rate=1.0,volume=50):
	if !text.is_empty():
		TTS.stop()
		TTS.speak(text, false, TTS.default_lang, pitch, rate, volume)
		
		timer.start(TIMER_COOLDOWN)
		
func is_cooled_down():
	return timer.is_stopped()
		
## Label reading methods

# Gets the name of a control
func get_accessible_name(obj):
	
	var name = null
	
	if obj.has_method("ax_custom_text"):
		var text = obj.ax_custom_text()
		if !text.is_empty():
			add_token(text)
			return
	
	if (obj is Label ||
		obj is LineEdit ||
		obj is TextEdit):
		get_accessible_label_name(obj)
	elif obj is RichTextLabel:
		get_accessible_richtext_label_name(obj)
	elif obj is OptionButton:
		get_accessible_optionbutton_name(obj)
	elif (obj is Button
		|| obj is LinkButton):
		get_accessible_button_name(obj)
	elif (obj is TextureRect):
		get_accessible_image_name(obj)
	elif (obj is ProgressBar):
		get_accessible_progress_bar_name(obj)
	elif (obj is SpinBox):
		get_accessible_spinbox_name(obj)
	elif obj is HSlider:
		get_accessible_hslider_name(obj)
	elif obj is VSlider:
		get_accessible_vslider_name(obj)
	elif obj is MenuBar:
		get_accessible_menubar_name(obj)
	elif obj is TabBar:
		get_accessible_tabbar_name(obj)
	else:
		# default name
		if obj.get("alt_text") != null && !obj.alt_text.is_empty():
			name = obj.alt_text
			add_token(name)
		else:
			name = obj.name
			add_token(name)
			
		if verbose:
			if obj.get_class() != name:
				add_token(obj.get_class())
	
# Gets the name for labels
func get_accessible_label_name(obj):
	var name = ""

	if focused is CodeEdit:
		var lines = focused.text.split("\n")
		
		add_token(get_character_name(lines[focused.get_caret_line()]))
		add_token(str(focused.get_caret_line()+1) + " " + TEXTEDIT_STRINGS[TEXTEDIT_STRING.LINE])
	
	else:
		name = obj.text
		add_token(name)
		
	if obj.get("alt_text") != null && !obj.alt_text.is_empty():
		name = obj.alt_text
		add_token(name)
		
	if verbose:
		if obj.get_class() != name:
			if focused is Label:
				add_token(SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.LABEL])
			else:
				add_token(obj.get_class()) 
			
# Gets the name for richtext labels
func get_accessible_richtext_label_name(obj):
	var name = ""
	
	if obj.get("alt_text") != null && !obj.alt_text.is_empty():
		name = obj
	else:
		name = obj.get_parsed_text()
		
	add_token(name)
			
	if verbose:
		if obj.get_class() != name:
			add_token(SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.LABEL])
			
# Gets the name for buttons
func get_accessible_button_name(obj):
	var name = ""
	
	if obj is CheckBox:
		if obj.button_pressed:
			add_token(POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.CHECKED])
		else:
			if verbose:
				add_token(POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.UNCHECKED])
				
	elif obj is CheckButton:
		if obj.button_pressed:
			add_token(POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.ON])
		else:
			add_token(POPUPMENU_CONTROL_NAMES[POPUPMENU_CONTROL.OFF])
				
	if obj.get("alt_text") != null && !obj.alt_text.is_empty():
		name = obj.alt_text
		add_token(name)
	else:
		name = obj.text
		add_token(name)
			
	if verbose:
		if obj.get_class() != name:
			var token = SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.BUTTON]
			if obj is CheckBox:
				token = SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.CHECKBOX]
			elif obj is CheckButton:
				token = SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.SWITCH]
			elif obj is MenuButton:
				token = SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.MENUBUTTON]
			elif obj is OptionButton:
				token = SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.DROPDOWN]
			add_token(token)
		
# Gets the name for images
func get_accessible_image_name(obj):
	var name = ""
	
	add_alt_text(obj)
			
	if verbose:
		if obj.get_class() != name:
			add_token(SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.IMAGE])
		
# Gets the name for progress bars
func get_accessible_progress_bar_name(obj):
	var name = ""
	
	# reads value
	
	if obj.get("read_fraction") != null:
		if obj.read_fraction:
			var text = STRING_FORMATS[STRING_FORMAT.FRACTION] % [str(obj.value), str(obj.max_value)]
			add_token(text)
			
		if obj.read_percent:
			var text = STRING_FORMATS[STRING_FORMAT.PERCENT] % [str(floor(100 * obj.value / obj.max_value))]
			add_token(text)
	else:
		# default if not accessible script
		var text = STRING_FORMATS[STRING_FORMAT.FRACTION] % [str(obj.value), str(obj.max_value)]
		add_token(text)
	
	add_alt_text(obj)
	
	if verbose:
		if obj.get_class() != name:
			add_token(SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.PROGRESS_BAR])
			
# Gets the name for spinboxes
func get_accessible_spinbox_name(obj):
	var name = ""
	
	# reads value
	add_token(str(obj.value))
	
	add_alt_text(obj)
	
	if verbose:
		if obj.get_class() != name:
			add_token(SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.SPINBOX])
		
# Gets the name for hslider
func get_accessible_hslider_name(obj):
	var name = ""
	
	get_accessible_slider_name(obj)
			
	if verbose:
		if obj.get_class() != name:
			add_token(SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.HSLIDER])
			
# Gets the name for vslider
func get_accessible_vslider_name(obj):
	var name = ""
	
	get_accessible_slider_name(obj)
			
	if verbose:
		if obj.get_class() != name:
			add_token(SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.VSLIDER])
		
func get_accessible_slider_name(obj):
	var name = ""
	
	# reads value
	
	if obj.get("read_fraction") != null:
		if obj.read_value:
			add_token(str(obj.value))
			
		if obj.read_fraction:
			var text = STRING_FORMATS[STRING_FORMAT.FRACTION] % [str(obj.value), str(obj.max_value)]
			add_token(text)
			
		if obj.read_percent:
			var text = STRING_FORMATS[STRING_FORMAT.PERCENT] % [str(floor(100 * obj.value / obj.max_value))]
			add_token(text)
	else:
		# default if not accessible script
		add_token(str(obj.value))
	
	add_alt_text(obj)
		
func get_accessible_menubar_name(obj):
	var properties = get_menubar_data(obj)
	
	var selected_menu = properties["selected_menu"]
	var size = obj.get_menu_count()
	var text = ""
	
	if selected_menu == null:
		selected_menu = 0

	if menubar_menu_opened(obj):
		var selected_index = properties["selected_index"]

		var popup = obj.get_menu_popup(selected_menu)
		var menu_size = popup.item_count
		
		if selected_index == null:
			selected_index = 0
		
		text = popup.get_item_text(selected_index)
		add_token(text)
		
		# Announce out of 3
		if verbose:
			if properties["selected_menu"] != null:
				text = STRING_FORMATS[STRING_FORMAT.FRACTION] % [str(selected_index+1), str(menu_size)]
				add_token(text)
		
		add_alt_text(obj)
		
		text = STRING_FORMATS[STRING_FORMAT.SELECTED] % [popup.name]
		add_token(text)
	else:
		var popup = obj.get_menu_popup(selected_menu)

		text = STRING_FORMATS[STRING_FORMAT.SELECTED] % [popup.name]
		add_token(text)
		
		# Announce out of 3
		if verbose:
			if properties["selected_menu"] != null:
				text = STRING_FORMATS[STRING_FORMAT.FRACTION] % [str(selected_menu+1), str(size)]
				add_token(text)
		
		add_alt_text(obj)
	
	if verbose:
		if obj.get_class() != name:
			add_token(SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.MENUBAR])
	
func get_accessible_tabbar_name(obj):

	var selected_menu = obj.current_tab
	var size = obj.tab_count
	
	var name = obj.get_tab_title(selected_menu)

	var text = STRING_FORMATS[STRING_FORMAT.SELECTED] % [name]
	add_token(text)
	
	# Announce out of 3
	if verbose:
		text = STRING_FORMATS[STRING_FORMAT.FRACTION] % [str(selected_menu+1), str(size)]
		add_token(text)
	
	add_alt_text(obj)
	
	if verbose:
		if obj.get_class() != name:
			add_token(SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.TABS])
	
# Gets the name for optionbuttons
func get_accessible_optionbutton_name(obj):
	var name = ""

	if focused.get_selected_id() > -1:
		add_token(STRING_FORMATS[STRING_FORMAT.SELECTED] % [focused.get_item_text(focused.get_selected_id())])
	else:
		add_token(STRING_FORMATS[STRING_FORMAT.SELECTED] % [TEXTEDIT_STRINGS[TEXTEDIT_STRING.NONE]])
		
	if obj.get("alt_text") != null && !obj.alt_text.is_empty():
		name = obj.alt_text
		add_token(name)
		
	if verbose:
		if obj.get_class() != name:
			if focused is Label:
				add_token(SPECIAL_CONTROL_NAMES[SPECIAL_CONTROLS.LABEL])
			else:
				add_token(obj.get_class()) 
	
# adds alt text	
func add_alt_text(obj):
	var name = ""
	
	# reads alt text, if any
	if obj.get("alt_text") != null && !obj.alt_text.is_empty():
		name = obj.alt_text
		add_token(name)
		
# Clear tokens
func clear_tokens():
	tokens = []
	
# adds token
func add_token(token):
	token = token.rstrip(" ").lstrip(" ").rstrip("\n").lstrip("\n")
	if token == ")":
		pass
	
	if(!token.is_empty()):
		tokens.append(token)
		
## Tree Building Methods

# Searches the tree starting at this node for UI elements to grab
func recursive_tree_search(obj,level=0):
	var inserted = false
		
	var current_objects;
		
	var created = 0;
	if is_marked_container(obj) == 1 || if_parent_is_TabContainer(obj):
		current_objects = array_stack[array_stack.size()-1]
		var new_array = []
		array_stack.append(new_array)
		current_objects.append(new_array)
		created += 1
		
	current_objects = array_stack[array_stack.size()-1]
		
	# Inserts under special conditions
	var node_type = get_node_type(obj)
	
	if (node_type == NODE_TYPE.INTERACT_NODE) && obj.get("ignore") != true:
		current_objects.append(obj)
		
		if obj is MenuBar:
			insert_menubar(obj)
		
		inserted = true
		
		# Tab bars add their children instead
		if obj is TabBar:
			var new_array = []
			array_stack.append(new_array)
			current_objects.append(new_array)
			# Go deeper in the recursion
			for c in obj.get_parent().get_children(true):
				if obj != c:
					recursive_tree_search(c,level+1)
			
			array_stack.pop_back()
			return true

	# If the node is not an end node
	if node_type != NODE_TYPE.INTERACT_NODE:
		# If the object has children
		if obj.get_child_count(true) > 0:
			# Go deeper in the recursion
			for c in obj.get_children(true):
				
				# if node is not programmic (unless tabbar
				if !obj.name.contains("@") || obj is TabBar:
					if recursive_tree_search(c,level+1):
						break
	
	for c in range(0,created):			
		array_stack.pop_back()
		
	return false

# Function to check if parent is tab container
func if_parent_is_TabContainer(obj):
	if obj.get_parent() is TabContainer && obj.get_parent().get_children().has(obj):
		return true
	else:
		return false

# Returns if the container is marked to be used as
# a container in the list.
# Returns 1 = true, 0 = false, -1 no property found
func is_marked_container(obj):
	if obj.get("focus_marked_container") != null:
		if obj.focus_marked_container && get_node_type(obj) == NODE_TYPE.CONTAINER:
			return 1
		return 0
			
	return -1

# Function to determine if list item is category or end item
func get_node_type(obj):
	
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

func get_object_list(list=objects):
	for c in list:
		if c is Array:
			get_object_list(c)
		else:
			if get_node_type(NODE_TYPE.INTERACT_NODE):
				end_node_list.append(c)
	
# Gets the object layers
func get_object_layer():
	var list = get_object_layer_rec()
	
	for c in range(list.size()-1, -1, -1):
		if list[c].is_empty():
			list.remove_at(c)
	
	return list

func get_object_layer_rec(list=objects, list_array=null, layer=0):
	if list_array == null:
		list_array = []
	
	if list_array.size() <= layer:
		list_array.append([])
	
	for c in list:
		if c is Array:
			get_object_layer_rec(c, list_array, layer+1)
		else:
			list_array[layer].append(c)
			
	return list_array

# gets the Focus Modes of all child elements

func build_focus_mode_list():
	object_focus_mode = []
	
	get_focus_mode_rec(dom_root, object_focus_mode)
	
# recursive function to get focus mode
func get_focus_mode_rec(obj, arr):
	for c in obj.get_children(true):
		if c is Control:
			arr.append(c.focus_mode)
			
			if c.get_child_count(true) > 0:
				var new_arr = []
				arr.append(new_arr)
				get_focus_mode_rec(c, new_arr)

# Sets all the focus objects to have no focus mode
func set_focus_off(obj):
	if obj != null:
		for c in obj.get_children(true):
			if c is Control:
				c.focus_mode = Control.FOCUS_NONE
				
				if c.get_child_count(true) > 0:
					set_focus_off(c)
				
func set_focus_on(obj, arr=object_focus_mode):
	if obj != null && !object_focus_mode.is_empty():
		var counter = 0
		for c in obj.get_children(true):
			if c is Control:
				c.focus_mode = arr[counter]
				counter += 1
				
				if c.get_child_count(true) > 0:
					set_focus_on(c,arr[counter])	
					counter+=1

# Highligher Functions

# redraws based on menu position
func highlight_normal():
	highlight_box = Rect2(focused.global_position,focused.size)
	call_deferred("queue_redraw")
	
# redraws based on menubar
func highlight_menubar():
	var properties = get_menubar_data(focused)
	
	var selected = properties["selected_menu"]
	
	var menu_count = focused.get_menu_count()
	
	# This will indicate that accessibility is not configued properly.
	# make sure you add the script
	if selected == null || menu_count < 1:
		highlight_box = Rect2(focused.global_position,focused.size)
	else:

		var h_sep = focused.get_theme_constant("h_separation")

		var len = 0
		var font_size = focused.get_theme_font_size("font_size")
		for c in range(0, selected):
			len += focused.get_theme_font("font").get_string_size(
							focused.get_menu_title(c) + " ",
							HORIZONTAL_ALIGNMENT_LEFT,
							-1,
							font_size).x
			
			len += h_sep*2

		var sizer = focused.get_theme_font("font").get_string_size(
						focused.get_menu_title(selected) + " ",
						HORIZONTAL_ALIGNMENT_LEFT,
						-1,
						font_size)
		
		
		highlight_box = Rect2(focused.global_position.x + float(len),
								focused.global_position.y,
								sizer.x + h_sep,
								sizer.y + font_size*0.5)

	call_deferred("queue_redraw")
	
# redraws based on tabbar
func highlight_tabbar():
		
	var tab_rect = focused.get_tab_rect(focused.current_tab)
		
	highlight_box = Rect2(
		focused.global_position.x + tab_rect.position.x,
		focused.global_position.y + tab_rect.position.y,
		tab_rect.size.x,
		tab_rect.size.y
	)

	call_deferred("queue_redraw")
	
# Sound functions

# Note, this sound object only 

# Init functions here, stuff like audio bank can be set.
func sound_init():
	add_child(sfx)

# plays a sound effect
# only from preloaded assets in SFX_LIBRARY
func play_sound(name, pitch=1):
	if sfx_enabled:
		if SFX_LIBRARY.has(name):
			sfx.stream = SFX_LIBRARY[name]
			sfx.pitch_scale = pitch
			sfx.play()
		
# stops a sound effect
func stop_sound():
	sfx.stop()
	
# Starts playing the sound for the slider
func timer_slider_timeout():
	play_sound("slider")
	
# Menubar Object Tracker functions

# Gets the menubar from object reference
func get_menubar_data(menubar):
	if menubars.has(menubar):
		return menubars[menubar]
	return {}

# Inserts menubar data into the dictionary
func insert_menubar(menubar):
	menubars[menubar] = create_menubar_object()

# This creates a new initialized menubar info object
func create_menubar_object():
	return {
		"selected_menu" : 0,
		"selected_index" : 0,
		"menu_opened" : false
	}
	
# Initializer Functions

# Gets the DOM state populated
func init_DOM():
	
	set_focus_on(dom_root)
	
	objects = []
	end_node_list = []
	menubars = {}
	array_stack = [objects]
	
	recursive_tree_search(dom_root)
	get_object_list()
	build_focus_mode_list()
	
func prdebug(string):
	if debug:
		print_debug(string)
		
# Inherited functions

# Runs when intialized
func _ready():
	# Makes it so that the selector always is drawn over the UI elements
	z_index = 100
	timer.one_shot = true
	timer_slider.one_shot = true
	timer_slider_increment.one_shot = true
	
	timer_slider.connect("timeout", timer_slider_timeout)
	add_child(timer)
	add_child(timer_slider)
	add_child(timer_slider_increment)
	sound_init()

# This forces reading the contents to override anything else.
func _input(event: InputEvent) -> void:
	if dom_nav_enabled:
		if Input.is_action_just_pressed("DOM_read_item"):
			if focused is CodeEdit:
				var lines = focused.text.split("\n")
				
				add_token(lines[focused.get_caret_line()])
			elif (focused is TextEdit
				|| focused is LineEdit):
				add_token(focused.text)
			else:
				add_token(get_accessible_name(focused))
			tts_speak()
			get_viewport().set_input_as_handled()
			
		# clear inputs if any DOM commands are pressed
		elif (Input.is_action_just_pressed("DOM_select") ||
				Input.is_action_just_pressed("DOM_cancel") ||
				Input.is_action_just_pressed("DOM_up") ||
				Input.is_action_just_pressed("DOM_down") ||
				Input.is_action_just_pressed("DOM_left") ||
				Input.is_action_just_pressed("DOM_right") ||
				Input.is_action_just_pressed("DOM_prev") ||
				Input.is_action_just_pressed("DOM_next") ||
				Input.is_action_just_pressed("DOM_read_item") ||
				Input.is_action_just_pressed("DOM_stop_talk") ||
				Input.is_action_just_pressed("DOM_item_decrement") ||
				Input.is_action_just_pressed("DOM_item_increment") ||
				Input.is_action_just_pressed("ax_start_video") ||
				Input.is_action_just_pressed("ax_stop_video")):
			get_viewport().set_input_as_handled()

# Processes the inputs for the DOM object
func _process(delta: float) -> void:
	process_input(delta)
	
# Draws additional stuff on top of the normal draw function
func _draw():
	
	# Draws the focused item if there is no focus stylebox
	if focused != null:
		draw_highlight()

# Draws the highlighted selection
func draw_highlight():
	draw_style_box(DEFAULT_FOCUS_STYLE, highlight_box)
	
# Updates what state to draw the current control in
func update_draw_state(state):
	control_state = state
	queue_redraw()
