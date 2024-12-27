# Best Practices

## Use AXController for Screenreader Control

Try to use only ``AXController`` functions for controlling the screenreader. All of the functions that you need to control the screenreader, high contrast mode and other accessibility features is interfaced in this class, so that a developer doesn't accidentally disrupt internal states of the screenreader.

## Group Relevant Controls Together

Navigation with the Previous/Next keys will navigate across the groups of Controls on the end nodes, making accessing different areas of the interface much easier. To make this feature more useful for screenreader users, use ``Control`` nodes as parents to groups of Controls, attach the ``ax_control.gd`` script, and make sure Focus Marked Container is checked. This will group all of the child nodes as a separate group for navigation.

## Minimize Inputs

It's important to reduce how many inputs a screenreader user needs to use in order to achieve tasks in your interface. For example, it may be more visually appealing to use a custom Label next to a CheckBox item in a menu. However, without any modification, this will lead to the screenreader needing two inputs to navigate past this function, when only one is really needed.

In this example, you can attach ``ax_label.gd`` to the Label Control, and make sure Ignore is checked. Then, you can attach ``ax_checkbox.gd`` to the CheckBox Control and set the Alt Text to the label of the previous Label. This configuration will reduce the number of input presses required to navigate the function from 2 to 1, and allows the developer to maintain control over how their interface is organized.

## Use Custom Controls

A lot of UI design in Godot requires building a Scene with developer-build custom Controls, often inheriting base Controls like Label, Button or TextureRect. When creating these Controls, it would be a good idea to set the root as a Control node, and attach ``ax_control.gd`` to it. Then, extend the script to its own script file so you can override functions and customize the control's functions. Finally, make sure Custom Control is checked. This will make it so that the screenreader ignores all the child controls and treats the Control as a Control in of itself.

> [!IMPORTANT]  
> Custom Controls do not have their own native input interactions, so you will need to override ``ax_function_override()``, ``ax_custom_text()`` and ``ax_screenreader_navigation()`` to allow for screenreader interactivity.

## Overriding Custom Control Functions

### Function Override

To give your Custom Control input functionality while the screenreader is active, you will need to override the ``ax_function_override()`` function. If this function returns true, the default function for this Control will be ignored. Even though for Control nodes, this makes no difference, it's a good idea to return true just in case this changes in the future. Here is a very simple example:

```
# If function interacts this frame,
# this is set to true.
var button_input: bool = false

func ax_function_override() -> bool:
    if Input.is_action_just_pressed("DOM_select"):
        AXController.add_token("You just selected!")
        AXController.read_tokens()
        button_input = true
        
    return true
```

> [!TIP]
> Use the DOM inputs when overriding this function. It will lead to more consistent behavior if keybinding is supported.

Take note of ``button_input``, this will be important later when overriding screenreader navigation.

### Custom Text

If ``ax_custom_text()`` returns a non-empty String, this String will be read instead of the default text. You can have it read a specific string of your choice, but it is more valuable to add tokens that explain different parts of the interface.

Here is an example of overriding this method to use tokens:

```
func ax_custom_text() -> String:
    AXController.add_token("Important Status")
    AXController.add_token("%s out of %s selected" % [str(3), str(5)])
    if Screenreader.verbose:
        AXController.add_token("Custom Control")
        
    return AXController.get_token_text()
```

This will output a string separated by pipe symbols (``|``) that announces the "Important Status", the element selected and, if Verbose mode is active, "Custom Control".

> [!TIP]
> Don't forget to add support for Screenreader.verbose support. This allows screenreaders to choose between a more verbose output or a shorter output.

> [!TIP]
> Order your tokens most important first, least important last. This way, the screenreader user has access to the most important information sooner.

### Ignoring Screenreader Navigation

Control input and screenreader navigation are handled separately. With default Control functions, it will skip screenreader navigation if an input on the Control is detected. However, with Custom Controls, you must control this behavior yourself by overriding the ``ax_screenreader_navigation()`` function. If this function returns false, screenreader navigation will be skipped this frame.

> [!NOTE]  
> This function only determines if screenreader navigation runs this frame. Screenreader navigation itself cannot be overridden.

Here is an example of overriding screenreader navigation. Take note of how ``button_input`` is used to control the return value of ``ax_screenreader_navigation()``. This causes ``ax_screenreader_navigation()`` to return false only on the next time it is called.

```
func ax_screenreader_navigation() -> bool:
    if button_input:
        button_input = false
        return false
        
    return true
```

[<- Previous (Extending Scripts)](extending_scripts.md)
 | [Next (Filesystem Structure) ->](filesystem_structure.md)

[Back to Index](index.md)

[Back to README](../../README.md)
