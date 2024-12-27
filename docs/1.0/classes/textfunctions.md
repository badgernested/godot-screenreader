# TextFunctions
Inherits: [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)

This class has text manipulation functions.

## Description

This class allows you to have specific text manipulation functions that are used by the screenreader.

## Methods

### get_action_keyboard_name_string()
``String get_action_keyboard_name_string(action: String, quantity: int = -1) static``

Returns a string with [action_name] replaced with the keyboard value it uses.


### get_character_name()
``String get_character_name(character: String) static``

Returns the long name for various characters, such as periods, commas etc.

### replace_all_keyboard_strings()
``String replace_all_keyboard_strings(text: String, quantity: int = -1) static``

Returns a string where all the possible inputs are replaced with the key used to trigger it. quantity refers to how many keys to print; by default, it will print all of them.

### singular_or_plural
``String singular_or_plural(count: int, singular: String, plural: String) static``

Returns the singular or plural form of a string, based on the quantity.

### unicode_is_capital
``bool unicode_is_capital(unicode: int) static``

Returns if a unicode value represents a capital letter.

[Back to Class Index](../classes.md)

[Back to Index](../index.md)

[Back to README](../../../README.md)

