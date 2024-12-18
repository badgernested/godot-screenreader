extends Control

## Button methods

# This exits the game
func _on_exit_button_pressed() -> void:
	get_tree().quit()

## Default methods

func _ready() -> void:
	DOMNavigator.set_dom_root($Panel)
	
	DOMNavigator.enable_dom()
	$Panel/Info/HBoxContainer/VersionNO.text += " " + ProjectSettings.get_setting("application/config/version")
	

func _on_play_pressed() -> void:
	var streamer = $Panel/Main/Panel/TabContainer/Media/VBoxContainer/VideoStreamPlayer;
	streamer.play_video()

func _on_pause_pressed() -> void:
	var streamer = $Panel/Main/Panel/TabContainer/Media/VBoxContainer/VideoStreamPlayer;
	streamer.pause_video()


func _on_stop_pressed() -> void:
	var streamer = $Panel/Main/Panel/TabContainer/Media/VBoxContainer/VideoStreamPlayer;
	streamer.stop_video()

# Adds elements to the tree
func _on_tree_ready() -> void:
	var trees = $"Panel/Main/Panel/TabContainer/More Elements/VBoxContainer/Tree"
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
			var item = tree.create_item(parent)
			item.set_text(0, file)
		file = dir.get_next()
	
	dir.list_dir_end()


func _on_test_menu_index_pressed(index: int) -> void:
	print("Index pressed: " + str(index))


func _on_extra_items_index_pressed(index: int) -> void:
	print("Number pressed: " + str(index))


func _on_strange_index_pressed(index: int) -> void:
	print("Button pressed: " + str(index))
