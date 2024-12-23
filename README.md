# Godot Screenreader

Work in progress.

Inspired by the work of [LightsOutGames](https://github.com/lightsoutgames/godot-accessibility), who created the first Godot accessibility plugin for Godot 3.x, and [rodolpheh](https://github.com/rodolpheh/godot-accessibility), who converted LightsOutGames' plugin to be used for Godot 4.x.

For now, it is something that can be used to attach to your game to make menus and other features more accessible. However, I hope to include this screenreader in a plugin in the future as well to make the Editor more accessible.

## Feature List

- Godot Screenreader
    - Support for the following controls:
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
        - OptionButton
        - MenuButton
        - Tree
            - Note: Tree Buttons are not supported.
    - Ability to ignore nodes if you so wish
    - Screenreader designed as standalone script
    - Additional scripts you can attach/extend to Control nodes to expand optional accessibility functionality, such as alt text
    - Tutorial
    - Control Type Navigator
- Subtitles and Audio Description
    - Video Streams support subtitles and audio description in ``VTT`` format (saved as ``.TXT`` files) 
- Themes
    - High contrast mode theme switcher

## Extra Information

If you want to know more about the screenreader, you can view the following:
- [Credits](CREDITS.md)
- [License - MIT](LICENSE)
