## NOTE! Menu bars will simply not be fully navigable if they
## do not use this script. I will investigate solutions later.

extends MenuBar

@export var focus_marked_container: bool = false
@export var alt_text: String = ""
@export var ignore: bool = false

# This is updated when navigated.
var selected_menu = 0
# Selected submenu index
var selected_index = 0
var menu_opened = false
