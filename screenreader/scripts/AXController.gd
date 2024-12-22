###############################################
# AXController
#
# This class controls all the other accessibility
# classes in one nice place.
###############################################
extends Control

static var pressed_keys = []
static var last_pressed_keys = []

# Strings for the screenreader functionality
const STRINGS = {
	"enabled" : "Screenreader enabled.",
	"disabled" : "Screenreader disabled."
}

const EVENT_FILE = "events.sav"
const AX_PATH = "ax/"

# An array of events, to prevent repeat events.
static var events: Array = []

# Whether or not the screenreader is enabled/disabled
static var _screenreader_enabled: bool = false

# The DOM root. if null, you can't open the screenreader.
static var dom_root: Control = null

# If true, loads events stored in a save file a frame
# after the instance loads.
# This way the screenreader tutorial only appears once
# when playing a game.
static var load_file: bool = false

func _ready():
	AXMenuManager.init(get_tree().get_root())
	Screenreader._do_ready(self)
	TextFunctions.update_keyboard_action_names()
	
	await get_tree().create_timer(0.001).timeout
	_load_events_from_file()

# This forces reading the contents to override anything else.
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
	
	var result = Screenreader._do_input(event)
	if result:
		get_viewport().set_input_as_handled()

# Processes the inputs for the DOM object
func _process(delta: float) -> void:
	last_pressed_keys = pressed_keys.duplicate()
	
	var changer = null
	
	# Enables/disabled screenreader
	if Screenreader.dom_root != null:
		changer = Screenreader.dom_root
	elif dom_root != null && dom_root is Node:
		changer = dom_root
		
	if Input.is_action_just_pressed("DOM_screenreader_enable"):
		if changer != null:
			_screenreader_enabled = !_screenreader_enabled
			
			var focus_node = _get_focus_node(changer)
			
			enable_screenreader(changer, _screenreader_enabled, focus_node)
			
	elif Input.is_action_just_pressed("DOM_screenreader_menu"):
		if Screenreader.dom_nav_enabled:
			if AXMenuManager._menu_stack.is_empty():
				AXMenuManager.push_menu("main")
	
	Screenreader._do_process(delta, self)
	
# Draws additional stuff on top of the normal draw function
func _draw():
	# Draws the focused item if there is no focus stylebox
	if Screenreader.focused != null:
		_draw_highlight()

# Draws the highlighted selection
func _draw_highlight():
	draw_style_box(HCController.get_focus_style(), Screenreader._highlight_box)

## Notification

func _notification(what: int):
	Screenreader._do_notification(what)
		
	if what == Control.NOTIFICATION_EXIT_TREE:
		_save_events_to_file()

# Returns if a key is pressed
func key_pressed():
	if key_changed():
		return last_pressed_keys.size() < pressed_keys.size()

# Returns if a key is changed	
func key_changed():
	if last_pressed_keys.size() != pressed_keys.size():
		return true
		
	for c in range(0, pressed_keys.size()):
		if pressed_keys[c] != last_pressed_keys[c]:
			return true
	
	return false

## Screenreader Control

# Enables the screenreader
func enable_screenreader(root: Control, enabled:bool = true, focus_obj: Control = null):
	
	var tutorial_pushed = false
	
	if enabled:
		add_token(STRINGS["enabled"])
		Screenreader.set_dom_root(root)
		
		if !_event_exists("TUTORIAL"):
			AXMenuManager.push_menu("tutorial")
			_add_event("TUTORIAL")
			tutorial_pushed = true
	else:
		add_token(STRINGS["disabled"])
		read_tokens()
	
	# If tutorial is pushed, dom is already enabled
	if !tutorial_pushed:
		Screenreader.enable_dom(enabled, focus_obj)
		
	update_screenreader_highlight()
	
func _set_screenreader_subject(root, enabled:bool = true, focus_obj: Control = null):
	await get_tree().create_timer(0.001).timeout
	Screenreader.set_dom_root(root)
	Screenreader.enable_dom(enabled, focus_obj)
	
# Clears the screenreader binding
func reset_screenreader():
	Screenreader.enable_dom(false)
	
# Updates the position of the screenreader highlighter
func update_screenreader_highlight():
	await get_tree().create_timer(0.001).timeout
	Screenreader._update_draw_highlight()
	queue_redraw()
	
# Focuses on a specific end node. Must be an end node.
func screenreader_focus(node: Control):
	Screenreader._update_end_node(node)

# Gets the focus node of the given node
func _get_focus_node(obj:Node):
	var focus_node = null
	
	var focus = obj.get("focus_node")

	if focus is NodePath:
		focus_node = obj.get_node(focus)
	
	return focus_node

## Accessibility themes

# Pass an element to make all its children 
# the dark high contrast theme
func set_high_contrast_dark_theme(root: Control):
	HCController.set_theme(root, "hc_dark")
	
# Pass an element to make all its children 
# the light high contrast theme
func set_high_contrast_light_theme(root: Control):
	HCController.set_theme(root, "hc_light")
	
# Passes an element to remove all special themes
func reset_theme(root: Control):
	HCController.reset_theme()
	
## Text to Speech manager

# Adds a token to the screen reader to be read.
func add_token(token: String):
	Screenreader._add_token(token)
	
# Reads the current tokens.
func read_tokens():
	Screenreader._tts_speak()
	
# Reads a tts string directly
func tts_speak(text: String, pitch:float = 1.0, rate:float= 1.0 , volume:int = 50):
	Screenreader._tts_speak_direct(text, pitch, rate, volume)

## Event manager

# Adds event
func _add_event(event):
	events.append(event)
	
# Removes event
func _remove_event(event):
	events.erase(event)
	
# Checks if event exists
func _event_exists(event):
	return events.has(event)

# Saves events to a file
func _save_events_to_file():
	if load_file:
		var dir = DirAccess.open("user://")
		
		if !dir.dir_exists(AX_PATH):
			dir.make_dir_recursive(AX_PATH)
			
		var path = "user://" + AX_PATH + EVENT_FILE
			
		var file = FileAccess.open(path,FileAccess.WRITE)
		
		for c in events:
			file.store_line(c)
		
		file.close()

# Loads data from the file
func _load_events_from_file():
	if load_file:
		var path = "user://" + AX_PATH + EVENT_FILE
		
		if FileAccess.file_exists(path):
			events = []
			var file = FileAccess.open(path, FileAccess.READ)
			
			while !file.eof_reached():
				events.append(file.get_line())
			
			file.close()
