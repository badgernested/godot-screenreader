# General Use

Whenever control would be given to a user interface, you can set up the screenreader by calling the following:

```
# root_node = The root node of your user interface
AXController.set_dom_root(root_node)
```

This will update how the screenreader organizes the Controls internally. For every time you need to update what buttons are able to be input by a user, you should call this.

If you want to clear the screenreader, you can call it with ``null``:

```
# root_node is set to null
AXController.set_dom_root(null)
```

> [!NOTE]  
> This is all that is necessary to get godot-screenreader running at a base level of functionality, but there are ways to organize your user interface and add/extend additional scripts to improve screenreader functionality. Check out this [document STUB](STUB.md) for more information.

## Changing Default Focus

By default, it will focus on the first selectable end node in the DOM. You can change this behavior, however, by passing an additional argument to ``AXController.set_dom_root()``.

```
# root_node = The root node of your user interface
# focus_node = The node to focus on when activated
AXController.set_dom_root(root_node, focus_node)
```

You can also change focus of the screenreader to any element contained in the DOM with the following function:
```
# node = the node you want to focus on
AXController.screenreader_focus(node)
```

## High Contrast Theming

The options menu includes support for high contrast theming of your UI Controls. If you want to update a control to use the currently set high contrast theme as set in the accessibility options menu, you can call the following method:

```
# node = the node you want to update the theme for
AXController.set_high_contrast_theme(node)
```

If you want to set *every* control in your SceneTree to use the current high contrast theme, you can just pass no argument like this:

```
# updating all Control nodes in the scene tree
AXController.set_high_contrast_theme()
```

You can also force the use of the light or dark high contrast themes with the following:

```
# this forces the light high contrast theme
AXController.set_high_contrast_light_theme(node)

# this forces the dark high contrast theme
AXController.set_high_contrast_dark_theme(node)
```

Finally, you can clear the high contrast theme with the following:
```
AXController.reset_high_contrast_theme()
```

## Screenreader Direct Text-to-Speech (TTS)

If you want to use the screenreader to read specific text, such as when designing custom controls with custom screenreader functionality, you may want to have the screenreader read text-to-speech (TTS) directly instead of depending on the screenreader's default functionality. Using the screenreader, there are two ways to do this - you can either load "tokens" that are read all at once, or you can read a TTS string directly.

> [!NOTE]  
> You can also use the ``TTS.speak()`` method to call TTS, however it will not take into consideration whether or not the screenreader is enabled, and will always read the text regardless.

### Using Tokens

You can add tokens to a list to be read later, which can be useful when gathering different pieces of information to read in your screenreader text for a custom control. To add a token, try this:

```
# adds a token to the text-to-speech reader
AXController.add_token("Hello world!")
```

Then, when you are ready to have the TTS read the tokens, you can call this:

```
# this reads all the tokens off in the TTS
AXController.read_tokens()
```

> [!NOTE]  
> Tokens will not be cleared until they are read off, so make sure you call ``AXController.read_tokens()``.

## Direct Reading

Sometimes you will want full control over what the screenreader is saying or even its pitch, rate and other features. To do this, you can call the following:

```
# text = the string to read
# pitch = the pitch to read it at, ranging from 0.0-2.0 with 1.0 in the middle
# rate = the relative rate to read it at, ranging from 0.0-2.0 with 1.0 in the middle
# volume = the relative volume to read it at, ranging from 0-100 with 50 in the middle
AXController.tts_speak(text, pitch, rate, volume)
```

[<- Previous (Installation)](installation.md)
 | [Next (Functionality) ->](functionality.md)

[Back to README](../../README.md)
