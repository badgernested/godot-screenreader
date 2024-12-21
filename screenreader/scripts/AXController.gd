###############################################
# AXController
#
# This class controls all the other accessibility
# classes in one nice place.
###############################################

extends Control

static var pressed_keys = []
static var last_pressed_keys = []

func _ready():
	Screenreader._do_ready(self)

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

func enable_screenreader(root):
	Screenreader.set_dom_root(root)
	Screenreader.enable_dom()
	
func reset_screenreader():
	Screenreader.enable_dom(false)

## Accessibility themes

# Pass an element to make all its children 
# the dark high contrast theme
func set_high_contrast_dark_theme(root):
	HCController.set_theme(root, "hc_dark")
	
# Passes an element to remove all special themes
func reset_theme(root):
	HCController.reset_theme(root)
