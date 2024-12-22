###############################################
# TextFunctions
#
# These are text manipulation functions.
###############################################
class_name TextFunctions
extends Object

const CHARACTER_NAMES = {
	" " : "Space",
	"." : "Period",
	"," : "Comma",
	";" : "Semicolon",
	"/" : "Forward Slash",
	"\\" : "Backslash",
	"+" : "Plus",
	"-" : "Dash",
	"*" : "Asterisk",
	"=" : "Equals Sign",
	"!" : "Exclaimation Point",
	"?" : "Question Mark",
	"@" : "At Symbol",
	"#" : "Pound Symbol",
	"$" : "Dollar Sign",
	"%" : "Percent",
	"^" : "Carat",
	"&" : "Ampersand",
	"(" : "Left Parentheses",
	")" : "Right Parentheses",
	"[" : "Left Bracket",
	"]" : "Right Bracket",
	"{" : "Left Curly Bracket",
	"}" : "Right Curly Bracket",
	"|" : "Pipe Symbol",
	"'" : "Apostrophe",
	"\"" : "Quotation Mark",
	":" : "Colon",
	">" : "Greater Than Symbol",
	"<" : "Less Than Symbol",
	"_" : "Underscore",
	"~" : "Tilde",
	"\t" : "Tab"
}

# Dictionary of action names
static var keyboard_action_names:Dictionary = {}

# checks if unicode is a capital letter
static func unicode_is_capital(unicode: int):
	return unicode >= 65 && unicode <= 90

# These are special key combos that are ignored for some purposes
static func special_key_combos():
	# paste
	if (AXController.pressed_keys.has(KEY_CTRL)
		&& AXController.pressed_keys.has(KEY_V)):
		return true
	
	return false
	
# Returns the string of certain characters
static func get_character_name(character: String):
	if !character.is_empty():
		character = character[0]
	else:
		character = " "
	
	for c in CHARACTER_NAMES:
		if c != " ":
			character = character.replace(c, " " + CHARACTER_NAMES[c] + " ")
	
	if CHARACTER_NAMES.has(character):
		return CHARACTER_NAMES[character]
	
	return character

# Gets all the action names
static func update_keyboard_action_names():
	keyboard_action_names = {}
	
	var actions = InputMap.get_actions()
	
	for c in actions:
		var events = InputMap.action_get_events(c)
		var keys = []
		for d in events:
			if d is InputEventKey:
				if d.keycode > 0:
					keys.append( OS.get_keycode_string(d.get_keycode_with_modifiers()))
				elif d.physical_keycode > 0:
					keys.append( OS.get_keycode_string(d.get_physical_keycode_with_modifiers()))
					
		if !keys.is_empty():
			keyboard_action_names[c] = keys
		
# Gets the keyboard buttons of the actions from the action name.
static func get_action_keyboard_name_string(action:String, quantity:int = -1):
	
	if !keyboard_action_names.has(action):
		return "[]"
		
	var action_data = keyboard_action_names[action]
	
	var ackt = ""
	
	if quantity <= -1:
		for c in action_data:
			ackt += c + ", "
			
		if ackt.length() > 1:	
			ackt = ackt.substr(0, ackt.length()-2)
	else:
		for c in range(0, min(quantity, action_data)):
			ackt += action_data[c] + ", "
		
		if ackt.length() > 1:	
			ackt = ackt.substr(0, ackt.length()-2)
		
	return "[%s]" % [ackt]

static func replace_all_keyboard_strings(text:String, quantity:int = -1):
	for c in keyboard_action_names:
		text = text.replace("[%s]" % c, get_action_keyboard_name_string(c, quantity))

	return text
