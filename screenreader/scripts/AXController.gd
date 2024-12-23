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
const OPTIONS_FILE = "options.sav"
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
static var load_file: bool = true

# If screenreader is enabled at start of game
static var start_screenreader: bool = false

# Set to true if fully initialized
static var fully_initialized: bool = false

func _ready():
	AXMenuManager.init(get_tree().get_root())
	Screenreader._do_ready(self)
	TextFunctions.update_keyboard_action_names()
	
	_load_options_from_file()
	
	await get_tree().create_timer(0.001).timeout
	_load_events_from_file()
	
	if is_instance_valid(dom_root) && start_screenreader:
		enable_screenreader(dom_root, start_screenreader)
		
	fully_initialized = true

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
				
		else:
			if AXMenuManager._menu_stack.is_empty():
				AXMenuManager.push_menu("options")
				
	Screenreader._do_process(delta)
	
	if Screenreader.clear_redraw:
		Screenreader.clear_redraw = false
		Screenreader.redraw = false
	
	if Screenreader.redraw:
		await get_tree().create_timer(0.001).timeout
		
		if Screenreader.redraw:
			Screenreader._update_draw_highlight()
			queue_redraw()
			Screenreader.redraw = false
	
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
		_save_options_to_file()

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

# Sets the DOM root.
func set_dom_root(obj: Control, focus_node:Control = null):
	dom_root = obj
	AXController.set_high_contrast_theme(obj)
	enable_screenreader(dom_root, _screenreader_enabled, focus_node)

# Enables the screenreader
func enable_screenreader(root: Control, enabled:bool = true, focus_obj: Control = null):
	
	var tutorial_pushed = false
	Screenreader.set_dom_root(root)
	
	if enabled:
		add_token(STRINGS["enabled"])
		
		if !_event_exists("TUTORIAL"):
			AXMenuManager.push_menu("tutorial")
			_add_event("TUTORIAL")
			tutorial_pushed = true
	else:
		if fully_initialized:
			add_token(STRINGS["disabled"])
			read_tokens()
		else:
			Screenreader._clear_tokens()
	
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
		if obj.has_node(focus):
			focus_node = obj.get_node(focus)
	
	return focus_node

## Accessibility themes

# Sets the theme to the currently selected accessibility theme
func set_high_contrast_theme(obj:Node=null):
	HCController.set_theme(obj)

# Pass an element to make all its children 
# the dark high contrast theme
func set_high_contrast_dark_theme(obj:Node=null):
	HCController.set_theme(obj, "hc_dark")
	
# Pass an element to make all its children 
# the light high contrast theme
func set_high_contrast_light_theme(obj:Node=null):
	HCController.set_theme(obj, "hc_light")
	
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

# Creates an options dictionary with the current state
func _create_options_dictionary():
	return {
		"sfx_enabled" : Screenreader.sfx_enabled,
		"wrap_nav" : Screenreader.navigation_wrap,
		"verbose" : Screenreader.verbose,
		"theme" : HCController.theme_style,
		"screenreader" : Screenreader.dom_nav_enabled,
		"subtitles" : Screenreader.subtitles_enabled,
		"adtts" : Screenreader.audio_description_enabled,
	}

# Saves events to a file
func _save_options_to_file():
	if load_file:
		var dir = DirAccess.open("user://")
		
		if !dir.dir_exists(AX_PATH):
			dir.make_dir_recursive(AX_PATH)
			
		var path = "user://" + AX_PATH + OPTIONS_FILE
			
		var file = FileAccess.open(path,FileAccess.WRITE)
		
		file.store_line(JSON.stringify(_create_options_dictionary()))
		
		file.close()

# Loads data from the file
func _load_options_from_file():
	if load_file:
		var path = "user://" + AX_PATH + OPTIONS_FILE
		
		if FileAccess.file_exists(path):
			var file = FileAccess.open(path, FileAccess.READ)
			
			var contents = JSON.parse_string(file.get_line())
			
			if contents.has("sfx_enabled"):
				Screenreader.sfx_enabled = bool(contents["sfx_enabled"])
			if contents.has("wrap_nav"):
				Screenreader.sfx_enabled = bool(contents["wrap_nav"])
			if contents.has("verbose"):
				Screenreader.sfx_enabled = bool(contents["verbose"])
			if contents.has("subtitles"):
				Screenreader.subtitles_enabled = bool(contents["subtitles"])
			if contents.has("adtts"):
				Screenreader.audio_description_enabled = bool(contents["adtts"])
			if contents.has("theme"):
				var str = contents["theme"]
				
				if str is String:
					HCController.theme_style = str.substr(0,min(10, str.length()))
			
			if contents.has("screenreader"):
				start_screenreader = bool(contents["screenreader"])
				
			file.close()
