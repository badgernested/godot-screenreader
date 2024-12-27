class_name TextFunctions
extends Object
## This class has text manipulation functions.
##
## This class allows you to have specific text manipulation
## functions that are used by the screenreader.

const _CHARACTER_NAMES = {
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

## Returns if a unicode value represents a capital letter.
static func unicode_is_capital(unicode: int) -> bool:
	return unicode >= 65 && unicode <= 90
	
## Returns the long name for various characters, such as periods, commas etc.
static func get_character_name(character: String) -> String:
	for c in _CHARACTER_NAMES:
		if c != " ":
			character = character.replace(c, " " + _CHARACTER_NAMES[c] + " ")
	
	if _CHARACTER_NAMES.has(character):
		return _CHARACTER_NAMES[character]
	
	return character
		
## Returns a string with [action_name] replaced with
## the keyboard value it uses.
static func get_action_keyboard_name_string(action:String, quantity:int = -1) -> String:
	
	if !AXController.keyboard_action_names.has(action):
		return "[]"
		
	var action_data = AXController.keyboard_action_names[action]
	
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

## Returns a string where all the possible inputs are replaced with the
## key used to trigger it. [param quantity] refers to how many keys to print;
## by default, it will print all of them.
static func replace_all_keyboard_strings(text:String, quantity:int = -1) -> String:
	for c in AXController.keyboard_action_names:
		text = text.replace("[%s]" % c, get_action_keyboard_name_string(c, quantity))

	return text

## Returns the singular or plural form of a string, based
## on the quantity.
static func singular_or_plural(count: int, singular: String, plural: String) -> String:
	if count == 1:
		return singular
	else:
		return plural
