extends Label

var focus = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("focus_entered",_focus_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	
func _draw():
	if focus:
		draw_style_box(preload("res://screenreader/ui/style/focus_end_node.tres"), Rect2(0,0,size.x, size.y))
	
func _focus_entered():
	focus = true
