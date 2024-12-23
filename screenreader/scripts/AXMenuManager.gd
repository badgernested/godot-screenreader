###############################################
# AXMenuManager
#
# This class manages menus, so you can push and
# pop menu interfaces easily.
#
# This should really only be used for the 
# screenreader. If you want your own menu
# manager for your game, you should base
# it off of this one instead.
###############################################
extends Node

# This contains the menus you're allowed to instantiate.
const MENUS = {
	"tutorial" : preload("res://screenreader/menu/ax/Tutorial.tscn"),
	"main" : preload("res://screenreader/menu/ax/AxMenu.tscn"),
	"node_select" : preload("res://screenreader/menu/ax/NodeSelector.tscn")
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
func init(root: Node):
	_root_node = root
	
# Focuses the menu on the top of the stack
func focus_top_menu():
	if !_menu_stack.is_empty():
		var menu = _menu_stack[_menu_stack.size()-1]
		var focus_node = AXController._get_focus_node(menu)
			
		# Select the previously selected node if able
		if menu.focused_element != null:
			focus_node = menu.focused_element
			
		if focus_node is TabContainer:
			focus_node = focus_node.get_child(0,true)
			
		AXController._set_screenreader_subject(menu, AXController._screenreader_enabled, focus_node)
	else:
		if _DOM_node != null:
			
			AXController._set_screenreader_subject(_DOM_node, AXController._screenreader_enabled, _focused_node)
			
			_focused_node = null
	
# Pushes the menu to the stack
func push_menu(menu_name: String):

	if MENUS.has(menu_name):
		if _menu_stack.is_empty():
			if Screenreader.dom_root != null && is_instance_valid(Screenreader.dom_root):
				_DOM_node = Screenreader.dom_root
				# Turns off the dom node
				Screenreader._set_focus_off(_DOM_node)
		else:
			var top = _menu_stack[_menu_stack.size()-1]
			top.set("focused_element", Screenreader.focused)
			
		var inst = MENUS[menu_name].instantiate()
		
		if _root_node != null:
			_root_node.call_deferred("add_child",inst)
			_menu_stack.append(inst)
			
			call_deferred("focus_top_menu")
			
		else:
			Screenreader._prdebug("You must first set _root_node with _init()")
	else:
		Screenreader._prdebug("Tried to push invalid ax menu %s" % [menu_name])

# Pops a menu from the stack
func pop_menu(quantity=1):
	TTS.stop()
	
	for c in range(0, quantity):
		var last_menu = _menu_stack.pop_back()

		if last_menu != null:
			last_menu.queue_free()
	
	call_deferred("focus_top_menu")
	
	AXController.call_deferred("update_screenreader_highlight")

# Pops everything from the menu stack
func pop_all():
	pop_menu(_menu_stack.size())

# Gets the top menu
func peek_menu():
	return _menu_stack[_menu_stack.size()-1]
