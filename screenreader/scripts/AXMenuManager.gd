extends Node
## This class manages internal menus used by the screenreader.
##
## This class manages internal menus used by the screenreader.
## It should not be used by developers for managing their own
## menus. Instead, developers should develop their own
## menu manager based on the structure of this one.

const _MENUS = {
	"tutorial" : preload("res://screenreader/menu/ax/Tutorial.tscn"),
	"main" : preload("res://screenreader/menu/ax/AxMenu.tscn"),
	"node_select" : preload("res://screenreader/menu/ax/NodeSelector.tscn"),
	"screenreader_options" : preload("res://screenreader/menu/ax/ScreenreaderOptions.tscn"),
	"options" : preload("res://screenreader/menu/ax/Options.tscn"),
}

# The original DOM node before switching to menu mode
var _DOM_node: Control = null

# Where the menu children are placed in the node tree.
var _root_node: Node = null

# The current menu stack.
var _menu_stack = []

# Node to focus on, if any
# This should be queued before finishing focus
var _focused_node = null

# Initializes the menu manuager
func _init_menu_manager(root: Node):
	_root_node = root
	
	
# Focuses the menu on the top of the stack
func _focus_top_menu():
	if !_menu_stack.is_empty():
		var menu = _menu_stack[_menu_stack.size()-1]
		var focus_node = AXController._get_focus_node(menu)
			
		# Select the previously selected node if able
		if menu.focused_element != null:
			focus_node = menu.focused_element
			
		if focus_node is TabContainer:
			focus_node = focus_node.get_child(0,true)
			
		AXController._set_screenreader_subject(menu, AXController._screenreader_enabled, focus_node)
		HCController.set_theme(menu)
		
		if menu.has_method("init"):
			menu.init()
	else:
		if _DOM_node != null:
			
			AXController._set_screenreader_subject(_DOM_node, AXController._screenreader_enabled, _focused_node)
			HCController.set_theme()
			
			_focused_node = null
	
# Pushes the menu to the stack
func _push_menu(menu_name: String):

	if _MENUS.has(menu_name):
		if _menu_stack.is_empty():
			if Screenreader.dom_root != null && is_instance_valid(Screenreader.dom_root):
				# Turns off the dom node
				Screenreader._set_focus_off(_DOM_node)
		else:
			var top = _menu_stack[_menu_stack.size()-1]
			top.set("focused_element", Screenreader.focused)
			
		var inst = _MENUS[menu_name].instantiate()
		
		if _root_node != null:
			_root_node.call_deferred("add_child",inst)
			_menu_stack.append(inst)
			
			call_deferred("_focus_top_menu")
			
		else:
			Screenreader._prdebug("You must first set _root_node with _init()")
	else:
		Screenreader._prdebug("Tried to push invalid ax menu %s" % [menu_name])

# Pops a menu from the stack
func _pop_menu(quantity=1):
	TTS.stop()
	
	for c in range(0, quantity):
		var last_menu = _menu_stack.pop_back()

		if last_menu != null:
			last_menu.queue_free()
	
	call_deferred("_focus_top_menu")
	
	AXController.call_deferred("update_screenreader_highlight")

# Pops everything from the menu stack
func _pop_all():
	_pop_menu(_menu_stack.size())

# Gets the top menu
func _peek_menu():
	return _menu_stack[_menu_stack.size()-1]
