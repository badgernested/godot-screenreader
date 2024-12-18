# Godot Screenreader

Work in progress.

Inspired by the work of [LightsOutGames](https://github.com/lightsoutgames/godot-accessibility), who created the first Godot accessibility plugin for Godot 3.x, and [rodolpheh](https://github.com/rodolpheh/godot-accessibility), who converted LightsOutGames' plugin to be used for Godot 4.x.

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
    - HSLider
    - VSlider
    - TextureRect (Only with script attached for alt text)
    - VideoStreamPlayer
- Screenreader designed as (mostly) standalone script
- Additional scripts you can attach/extend to Control nodes to expand optional accessibility functionality, such as alt text
- Video Streams support subtitles and audio captions in ``VTT`` format (saved as ``.TXT`` files) 
