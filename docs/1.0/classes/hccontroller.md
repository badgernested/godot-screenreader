# HCController
Inherits: [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)

This class controls high contrast mode.

## Description

This class controls high contrast mode. Typically, you should control high contrast themes through AXController instead.

## Properties


### theme_style

| Return Type | Default Value |
|:-------------:|:-------------:|
| ``String`` | ``"none"``

The name of the current high contrast theme active.


## Methods

### get_focus_style()
``StyleBox get_focus_style() static``

Gets the current StyleBox of the focus selector.

### get_gradient()
``Texture2D get_gradient() static``

Gets the gradient for the currently selected high contrast theme.

### get_style()
``Theme get_style() static``

Gets the currently selected high contrast theme.

### reset_theme()
``void reset_theme() static``

Resets the high contrast theme.

### set_theme()
``void set_theme(root: Node = null, theme: String = theme_style) static``

Sets the theme to a new theme based on the theme style name.

[Back to Class Index](../classes.md)

[Back to Index](../index.md)

[Back to README](../../../README.md)

