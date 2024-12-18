# Godot Screenreader

Work in progress.

Inspired by the work of [LightsOutGames](https://github.com/lightsoutgames/godot-accessibility), who created the first Godot accessibility plugin for Godot 3.x, and [rodolpheh](https://github.com/rodolpheh/godot-accessibility), who converted LightsOutGames' plugin to be used for Godot 4.x.

For now, it is something that can be used to attach to your game to make menus and other features more accessible. However, I hope to include this screenreader in a plugin in the future as well to make the Editor more accessible.

## Feature List

- Godot Screenreader with support for the following controls:
    - Label
    - RichTextLabel
    - MenuBar
    - Button
    - LinkButton
    - CheckBox
    - CheckButton
    - LineEdit
    - TextEdit
    - CodeEdit
    - ProgressBar
    - SpinBox
    - HSlider
    - VSlider
    - TextureRect (Only with script attached for alt text)
    - VideoStreamPlayer
- Ability to ignore nodes if you so wish
- Screenreader designed as (mostly) standalone script
- Additional scripts you can attach/extend to Control nodes to expand optional accessibility functionality, such as alt text
- Video Streams support subtitles and audio captions in ``VTT`` format (saved as ``.TXT`` files) 
