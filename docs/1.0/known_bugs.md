# Known Bugs

## High Contrast Theme Bugs

There are some bugs with High Contrast themes.

- OptionMenu text is not readable when Control is focused after selecting an option.

## MenuBar Bugs

[MenuBar](https://docs.godotengine.org/en/stable/classes/class_menubar.html) is a Control type that generates a row of buttons that open menus, similar to the top menu bar seen in many Windows applications. This Control is pretty difficult to work with and there are a few bugs associated with this Control.

> [!NOTE] 
> While this Control is included for compatibility purposes, it can be problematic to use. If you don't need MenuBar's specific functionality, it would be better to have an array of MenuButton controls. They will give you more consistent control and behavior than MenuBar.

- Screenreader highlighter does not properly line up with elements of this control.
- MenuBar popup's inputs cannot be fully turned off, leading to inconsistent behavior between MenuButton and MenuBar.


[<- Previous (Scripts)](scripts_info.md)

[Back to Index](index.md)

[Back to README](../../README.md)
