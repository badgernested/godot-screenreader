# Extending Scripts

- [Extending Scripts](#extending-scripts)
  * [Function Overrides](#function-overrides)
    + [Custom Input](#custom-input)
    + [Custom Selection Text](#custom-selection-text)
    + [Override Screenreader Navigation](#override-screenreader-navigation)
  * [Custom Controls](#custom-controls)

Extending the screenreader scripts will allow your Controls to be even more customized when interacting with the screenreader. Extending scripts also allows you to add custom functionality to your Controls like you normally would, while allowing you to use the extended screenreader functionality.

> [!IMPORTANT]  
> In addition to extending screenreader functionality, if you want to both use the script and have custom behavior on a Control, you should also extend the script. Do not modify the base scripts since this could negatively impact other parts of the game.

## Function Overrides

There are multiple functions you can override to customize and tweak screenreader behavior. For example, you may have created a custom Control that has a unique input scheme. These functions can be overridden to modify these behaviors.

### Custom Input

If you want to override how the screenreader interacts with the Control, you can override the ``ax_function_override()`` function.

This function is called before any screenreader input is processed. If this function returns ``true``, it will ignore default processing for that Control type.

### Custom Selection Text

When the Control is selected by the screenreader, if you want custom text selection logic, you can override the ``ax_custom_text()`` function.

This function is called when trying to generate the Control's selected text. If this function returns anything besides an empty String, it will read this text instead of the default text.

### Override Screenreader Navigation

Screenreader navigation is handled after Control input. The default Controls will only trigger the navigation if the Control does not have any inputs. You can disable the screenreader navigation by overridding the ``ax_screenreader_navigation()`` function.

If this function returns false, the screenreader navigation will be ignored.

## Custom Controls

If you create a custom control in your own scene file or within the SceneTree, you can attach ``ax_control.gd`` to it and check Custom Control. This allows the control to be treated as a single item instead of trying to group all of the children controls as separate items.

Additionally, since the Control acts as its own end node, you will have to override ``ax_function_override()``, ``ax_custom_text()`` and ``ax_screenreader_navigation()`` to add screenreader input interactivity with the Control, or else it won't do anything.

[<- Previous (Using Scripts)](using_scripts.md)
 | [Next (Best Practices) ->](best_practices.md)

[Back to Index](index.md)

[Back to README](../../README.md)
