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

# checks if unicode is a capital letter
static func unicode_is_capital(unicode):
	return unicode >= 65 && unicode <= 90

# These are special key combos that are ignored for some purposes
static func special_key_combos():
	# paste
	if (ScreenreaderController.pressed_keys.has(KEY_CTRL)
		&& ScreenreaderController.pressed_keys.has(KEY_V)):
		return true
	
	return false
	
# Returns the string of certain characters
static func get_character_name(character):
	for c in CHARACTER_NAMES:
		if c != " ":
			character = character.replace(c, " " + CHARACTER_NAMES[c] + " ")
	
	if CHARACTER_NAMES.has(character):
		return CHARACTER_NAMES[character]
	
	return character
