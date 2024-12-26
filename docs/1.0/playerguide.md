# A Player's Guide

Hey there! You seem to be a confused player. Perhaps a developer sent you this way to help explain how to interact with a screenreader that their game is using. This guide will help you get started.

## Demo Quick Start

The following guide will allow you to easily navigate the demo ([Windows](https://github.com/badgernested/godot-screenreader/raw/refs/heads/main/exports/windows/demo.zip)/[Linux](https://github.com/badgernested/godot-screenreader/raw/refs/heads/main/exports/linux/demo.tar.gz)).

Once you open the demo, you can press the F2 key to open the screenreader. You should hear the screenreader announce that it is enabled, and it will display a tutorial. It's recommended you navigate this tutorial if its the first time you've ever used godot-screenreader. Afterward, you can navigate the user interface's visible elements using the Up and Down keys, or Tab and Shift + Tab. If you want to see more elements, you can navigate the tabs to view different kinds of items, like sliders, media elements and a tree navigator.

You can view screenreader tools by pressing F5. 
- Control Navigator - Navigate through different types of controls, such as labels, textboxes etc. through the entire interface.
- Options - Configure the screenreader.
- Tutorial - You can view the tutorial again.

## Default Inputs

Here is a summary listing the default inputs of the screenreader:

| Key          | Summary  |
|:-------------:|:-------------:|
| F2 | Enables the screenreader. |
| F5 | Opens the screenreader menu. |
| F3 | Reads the description text of the currently selected control. |
| F4 | Stops the TTS voice talking. |
| Shift + Tab | Navigates to the previous tabable control or area. |
| Tab | Navigates to the next tabable control or area. |
| Up | Navigates to the next visible selectable control. |
| Down | Navigates to the previous visible selectable control. |
| Left | Navigates to the previous item within a selected control. |
| Right | Navigates to the next item within a selected control. |
| Enter | Selects an item within a selected control. |
| Escape | Cancels a selection within a selected control. |
| Shift + S | Stops video for ``VideoStreamPlayer`` instances attached with the accessibility script |
| Shift + A | Plays video for ``VideoStreamPlayer`` instances attached with the accessibility script |

> [!NOTE]  
> Developers can change the inputs for any of these inputs, so refer to the developer documentation as well.

[Next (Introduction) ->](intro.md)

[Back to Index](index.md)

[Back to README](../../README.md)
