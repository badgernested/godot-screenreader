extends Control

func _on_tree_ready() -> void:
	var trees = $"Tab/Trees/HBox/SampleArea/Tree"
	trees.set_column_title(0, "Test Tree")
	var root = trees.create_item()
	root.set_text(0,"res://")
	tree_render(trees, root, "res://")
	
func tree_render(tree, parent, filepath):
	var dir = DirAccess.open(filepath)
	
	dir.list_dir_begin()
	
	var file = dir.get_next()
	
	while file != "":
		
		if dir.dir_exists(file):
			var item = tree.create_item(parent)
			item.set_text(0, file)
			tree_render(tree, item, filepath + "/" + file)
		else:
			if !file.ends_with(".import"):
				var item = tree.create_item(parent)
				item.set_text(0, file)
		file = dir.get_next()
	
	dir.list_dir_end()

# Exits the tutorial
func _on_button_pressed() -> void:
	AXMenuManager.pop_menu()
