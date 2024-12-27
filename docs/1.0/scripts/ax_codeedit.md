# ax_codeedit
Inherits: [CodeEdit](https://docs.godotengine.org/en/stable/classes/class_codeedit.html)

Script for adding additional accessibility function to CodeEdit Controls.

## Description

This script is designed to extend functionality for the CodeEdit Control to godot-screenreader. Extend this script to add additional functionality such as custom screenreader text and input.

## Properties

###  alt_text

| Return Type | Default Value |
|:-------------:|:-------------:|
| ``String`` | ``""``

This Control's alt text.

### draw_highlight
| Return Type | Default Value |
|:-------------:|:-------------:|
| ``bool`` | ``true``

If true, the highlight surrounding the control when it is selected is drawn.

### enable_mouse
| Return Type | Default Value |
|:-------------:|:-------------:|
| ``bool`` | ``false``

If true, this node is set to focus_mode = FOCUS_MODE_CLICK instead of FOCUS_MODE_NONE when the screenreader has loaded this Control.

### ignore
| Return Type | Default Value |
|:-------------:|:-------------:|
| ``bool`` | ``false``

Whether or not this Control is ignored during navigation generation.

## Methods

### ax_custom_text()
``String ax_custom_text()``

If this value returns a non-empty value, it will read that string instead of the default string for the screenreader when it reads its name.

### ax_function_override()
``bool ax_function_override()``

When this function returns true, it will override the regular input function of the control. Note that this will require you to manually insert all emit_signal calls.

### ax_screenreader_navigation()
``bool ax_screenreader_navigation()``

If this method returns true, the default screenreader navigation functionality will still be called. Typically if you did some other functionality this frame, you don't want to trigger navigation too. So make this return false if you trigger functionality this frame.

[Back to Script Index](../scripts_info.md)

[Back to Index](../index.md)

[Back to README](../../../README.md)
