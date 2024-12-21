###############################################
# DomController
#
# The default interface for the global. This way,
# the screenreader can be static and this just
# controls the screenreader in the node tree.
###############################################

extends Control

func _ready():
	Screenreader.do_ready(self)

# This forces reading the contents to override anything else.
func _input(event: InputEvent) -> void:
	Screenreader.do_input(event)

# Processes the inputs for the DOM object
func _process(delta: float) -> void:
	Screenreader.do_process(delta, self)
	
# Draws additional stuff on top of the normal draw function
func _draw():
	# Draws the focused item if there is no focus stylebox
	if Screenreader.focused != null:
		_draw_highlight()

# Draws the highlighted selection
func _draw_highlight():
	draw_style_box(Screenreader.DEFAULT_FOCUS_STYLE, Screenreader._highlight_box)

## Notification

func _notification(what: int):
	Screenreader.do_notification(what)
