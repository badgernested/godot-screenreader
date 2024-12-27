# Usage Summary

- [Usage Summary](#usage-summary)
  * [General Use](#general-use)
    + [Screenreader](#screenreader)
      - [Custom TTS](#custom-tts)
        * [Tokens](#tokens)
        * [Direct Reading](#direct-reading)
    + [High Contrast Theme](#high-contrast-theme)
  * [Using Scripts](#using-scripts)

## General Use

All of the accessibility features provided in godot-screenreader either happen automatically, or can be controlled through the ``AXController`` global node. 

> [!WARNING]  
> There are other classes and nodes used to manage the functionality in godot-screenreader. Don't mess with these, unless you really know what you're doing, since they can disrupt the internal expectations of the screenreader.

### Screenreader

To load a new UI into the screenreader, call ``AXController.set_dom_root(root_node)``, where ``root_node`` is the top node of your UI, that contains all and only elements that you want to be interacted with. It is important that ``root_node`` contains all of the Controls you want to navigate through the screenreader, since ``AXController.set_dom_root()`` recursively searches the node's children to construct its navigation data.

```
# root_node = The root node of your user interface
AXController.set_dom_root(root_node)
```

To release screenreader control while the screenreader is enabled, pass ``null`` as the argument instead: ``AXController.set_dom_root(null)``. This way, you can write your own routines for parts of the game that do not use Control inputs.

```
# root_node is set to null
AXController.set_dom_root(null)
```

#### Custom TTS

Sometimes, you will want to read off custom strings to the screenreader, such as when building custom controls. There are two ways to do this. You can populate a list of tokens, or you can directly call the screenreader's TTS function.

> [!NOTE]  
> You can also use the ``TTS.speak()`` method to call TTS, however it will not take into consideration whether or not the screenreader is enabled, and will always read the text regardless.

##### Tokens

Tokens are strings stored in a list that are read all at once. They can be used to prepare a string with information about a certain Control to later be read by a screenreader. To add a token, call ``AXController.add_token()`` and pass the string of the token you want to add.

```
AXController.add_token("Hello world!")
```

When you want to read the tokens, simply call ``AXController.read_tokens()``. This will read all the tokens as a string in the screenreader's TTS.

```
AXController.read_tokens()
```

Under some circumstances you may want to also clear tokens without reading them. You can do this by calling ``AXController.clear_tokens()``.

```
AXController.clear_tokens()
```

##### Direct Reading

To directly call the screenreader's TTS with a given string, you can call ``AXController.tts_speak()``. This function not only allows you to pass a string directly, but you can also pass different modifiers, such as pitch, speaking rate and volume.

```
AXController.tts_speak(text, pitch, rate, volume)
```

### High Contrast Theme

You can update the state of the high contrast theme by calling ``AXController.set_high_contrast_theme(root_node)``, where ``root_node`` is the top root node of all the controls you want to update the state of.

Passing no argument to ``AXController.set_high_contrast_theme()`` will use the SceneTree as the root. However, this might be a costly function depending on how many nodes are in your SceneTree.

You can force high contrast modes, either light or dark mode, with ``AXController.set_high_contrast_light_theme()`` and ``AXController.set_high_contrast_dark_theme()`` respectively. Like ``AXController.set_high_contrast_theme()``, you can pass no argument to reset the theme from the SceneTree root.

Finally, if you need to reset to the original developer-designated theme, you can call ``AXController.reset_high_contrast_theme()``.

## Using Scripts

Scripts allow for extended functionality to nodes, such as adding alt text, ignoring nodes, or alternative functions for reading the contents of a Control. They are also required to be used to support videos with subtitles or audio description.

To use a script, simply drag the appropriate script onto the Control. These scripts are located in ``res://addons/godot-screenreader/scripts/object_scripts/``.

> [!IMPORTANT]  
> Make sure you use the script that extends the Control type that you are attaching your script to, or else you will have errors.

Scripts will allow you to have extended functionality, such as:
- Alt Text - This is additional text that describes what a control is, represents or doing.
- Ignore - Ignore this Control when building the navigation tree.
- Enable Mouse - This causes a Control to use ``FOCUS_MODE_CLICK`` instead of ``FOCUS_MODE_NODE`` to control inputs. (Focus mode is changed for Controls to prevent interference with the normal UI control)
- Draw Highlight - Whether or not the screenreader highlighter should draw around the selected element.
- Focus Marked Container - Only used on Control and a few container nodes. This marks this Control as creating a separate navigation group for child elements. 

[<- Previous (Features)](functionality.md)
 | [Next (Using Scripts) ->](using_scripts.md)

[Back to Index](index.md)

[Back to README](../../README.md)
