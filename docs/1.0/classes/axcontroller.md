# AXController
Inherits: [Control](https://docs.godotengine.org/en/stable/classes/class_control.html)

This class controls all the other accessibility classes in one nice place.

## Description

This is the main Node to interact with to control the screenreader and other accessibility functions in godot-screenreader.

## Constants

### EVENT_FILE
``EVENT_FILE = "events.sav"``

Location of the screenreader events file. Used for displaying tutorials once.

### OPTIONS_FILE
``OPTIONS_FILE = "options.sav"``

Location of the screenreader options file.

### AX_PATH
``AX_PATH = "ax/"``

Directory of screenreader files.

## Properties

### dom_root
| Return Type | Default Value |
|:-------------:|:-------------:|
| ``Control`` | ``null``

The DOM root. If null, you can't open the screenreader.

### keyboard_action_names
| Return Type | Default Value |
|:-------------:|:-------------:|
| ``Dictionary`` | ``{}``

This contains a dictionary where all the keys are action names and the values are an array of all keyboard inputs associated with that action.

### last_pressed_keys
| Return Type | Default Value |
|:-------------:|:-------------:|
| ``Array`` | ``[]``

The keys pressed last frame.

### load_file
| Return Type | Default Value |
|:-------------:|:-------------:|
| ``bool`` | ``true``

If true, loads events stored in a save file a frame after the instance loads. This way the screenreader tutorial only appears once when playing a game.

### pressed_keys
| Return Type | Default Value |
|:-------------:|:-------------:|
| ``Array`` | ``[]``

The keys pressed this frame.

### start_screenreader
| Return Type | Default Value |
|:-------------:|:-------------:|
| ``bool`` | ``false``

If screenreader is enabled at start of game.

## Methods

### add_token()

``void add_token(token: String)``

Adds a token to the screen reader to be read.

### clear_tokens()

``void clear_tokens()``

Clears the tokens stored.

### key_changed()
``bool key_changed()``

Returns true if the state of key presses has changed this frame.

### key_pressed()
``bool key_pressed()``

Returns true if a key has been pressed this frame.

### read_tokens()
``void read_tokens()``

Reads the current tokens.

### reset_high_contrast_theme()
``void reset_high_contrast_theme(root: Control)``

Passes an element to remove all special themes

### screenreader_focus()
``void screenreader_focus(node: Control)``

Focuses on a specific end node. Must be an end node.

### set_dom_root()
``void set_dom_root(obj: Control, focus_node: Control = null)``

Sets the DOM root.

### set_high_contrast_dark_theme()
``void set_high_contrast_dark_theme(obj: Node = null)``

Pass an element to make all its children the dark high contrast theme

### set_high_contrast_light_theme()
``void set_high_contrast_light_theme(obj: Node = null)``

Pass an element to make all its children the light high contrast theme

### set_high_contrast_theme()
``void set_high_contrast_theme(obj: Node = null)``

Sets the theme to the currently selected accessibility theme

### special_key_combos()
``bool special_key_combos() static``

Returns if a special key combo is being pressed.

### tts_speak()
``void tts_speak(text: String, pitch: float = 1.0, rate: float = 1.0, volume: int = 50)``

Reads a TTS string directly.

### update_keyboard_action_names()
``void update_keyboard_action_names()``

Updates the keyboard action names stored in keyboard_action_names.

### update_screenreader_highlight()
``void update_screenreader_highlight()``

Updates the position of the screenreader highlighter.

[Back to Class Index](../classes.md)

[Back to Index](../index.md)

[Back to README](../../../README.md)

