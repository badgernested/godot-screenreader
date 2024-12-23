extends Control

var end_nodes: Array = []

func _ready() -> void:
	populate_node_selectors()
	
func _process(delta: float) -> void:
	pass

func populate_node_selectors():
	Screenreader.set_dom_root(AXMenuManager._DOM_node)
	
	end_nodes = Screenreader._end_node_list.duplicate()
	
	for c in $TabContainer.get_children():
		if c.has_node("Button"):
			var node = c.get_node("Button")
			
			var content_array = []
			
			for d in end_nodes:
				if c.name == "Labels":
					if (d is Label ||
						d is RichTextLabel):
							content_array.append(d)
				elif c.name == "Buttons":
					if (d is BaseButton):
							content_array.append(d)
				elif c.name == "Textboxes":
					if (d is LineEdit ||
						d is TextEdit):
							content_array.append(d)
				elif c.name == "Sliders":
					if (d is SpinBox ||
						d is ProgressBar ||
						d is VSlider ||
						d is HSlider):
							content_array.append(d)
				elif c.name == "Media":
					if (d is VideoStreamPlayer ||
						(d is TextureRect &&
							d.get("alt_text") != null &&
							d.get("alt_text").lstrip(" ").rstrip(" ").length() > 0)):
							content_array.append(d)
				else:
					if (d is Tree ||
						d is TabBar ||
						d is MenuBar):
							content_array.append(d)
			
			node.objects = content_array
			


func _on_tree_exited() -> void:
	for c in AXMenuManager._menu_stack:
		c.modulate = Color(1.0, 1.0, 1.0, 1.0)
