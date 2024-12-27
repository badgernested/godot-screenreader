# Features

- [Features](#features)
  * [Screenreader](#screenreader)
    + [Supported Base Controls](#supported-base-controls)
    + [Sound Effects](#sound-effects)
    + [Verbose Mode](#verbose-mode)
    + [Customization Scripts](#customization-scripts)
  * [High Contrast Themes](#high-contrast-themes)
  * [VTT Encoder](#vtt-encoder)

## Screenreader

The screenreader is a tool that, when enabled, allows users to navigate a tree of controls. Users can navigate either one control at a time, navigate by groups of controls, or use tools to navigate through all buttons, labels or other control types.

### Supported Base Controls

The following controls are all supported by default.

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
- TextureRect
    - Only supported if script is attached and alt text is assigned.
- VideoStreamPlayer
- OptionButton
- MenuButton
- Tree
    - Tree Buttons are not supported.
    
### Sound Effects

In addition to reading off controls, there are additional sound effects that are played as a player navigates the user interface. This can help signal when a user is interacting with certain controls, or navigating using certain tools. Sound effects can also be disabled if the user desires.

### Verbose Mode

Verbose mode reads more information about the selected controls to the user. This allows users to decide to pick between having more information and taking their time, or less information and being quick. Verbose mode can be enabled or disabled by the user, and is enabled by default.

### Customization Scripts

You can add additional functionality to controls by attaching or extending the scripts contained in ``res://addons/godot-screenreader/scripts/object_scripts/``. These scripts can be attached to various controls to add features like alt text, grouping certain controls together, ignoring the control or customization on how the control's contents are read by the screenreader. These allow for high levels of control and customization by simply attaching the appropriate script to your control.

> [!NOTE]  
> ``Texture2D`` requires the script ``ax_texturerect.gd`` to be attached, and requires alt text to be set to be visible to the screenreader.

Additionally, you can extend these scripts to access additional functionality. Each script contains additional methods that can be extended to modify the control's functionality, such as changing how its text is read, or how UI input works with the control in screenreader mode.

## High Contrast Themes

There are two high contrast themes that can override other themes assigned by the developer - light and dark. These themes allow for users to more clearly see the contents of their user interfaces. These themes can even be used when the screenreader is not enabled.

## VTT Encoder

VTT-formated files are files that are used for displaying subtitles. For example, on social media, VTT files are what displays the correct subtitles on the correct times on videos. godot-screenreader supports parsing VTT files for ``VideoStreamPlayer`` controls and displaying subtitles when the control has its special customization script attached or extended. It can also use VTT-formated files to read audio descriptions in TTS. Audio descriptions describe what is visually happening in a video for visually impaired users.

> [!NOTE]  
> VTT files are stored as ``.txt`` files, not as ``.vtt`` files, because of Godot's restrictive allowed file types in projects.

[<- Previous (General Use)](generaluse.md)
 | [Next (Usage Summary) ->](usage_summary.md)

[Back to Index](index.md)

[Back to README](../../README.md)
