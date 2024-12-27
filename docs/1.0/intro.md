# Introduction

- [Introduction](#introduction)
  * [Technical Details](#technical-details)
  * [What are the Other Features Provided by This Asset?](#what-are-the-other-features-provided-by-this-asset)
  * [What are Upcoming (Hopefully) Features for This Asset?](#what-are-upcoming-hopefully-features-for-this-asset)

godot-screenreader is an asset/tool that you can add on to your Godot projects to install a screenreader for navigating Control nodes. A screenreader allows for improved accessibility of menu controls so that blind or visually impaired users, among others, can better tell what is on the screen.

## Technical Details

godot-screenreader is designed to work on versions of Godot 4.3+. If you need a screenreader or Text-to-Speech (TTS) functionality for Godot 3.x, consider using [godot-tts](https://github.com/lightsoutgames/godot-tts) by [LightsOutGames](https://www.lightsout.games/) instead.

Currently, godot-screenreader is confirmed to work on Windows and Linux platforms.

godot-screenreader has not yet been tested with braille displays. 

## What are the Other Features Provided by This Asset?

There are a few extra accessibility features that are bundled in with this asset, for ease of access to the developer:

- High-Contrast Themes
    - Replace temporarily all themes on a Control and all of its children to a high contrast theme.
    - Dark and light modes are supported.
- Subtitles/Audio Description of Videos
    - VTT parser and the ability to display subtitles on videos.
    - VTT format can be used for subtitles or TTS Audio Description.
    
## What are Upcoming (Hopefully) Features for This Asset?

This is an early release of this accessibility asset, so not all desired features are supported yet. Some goals down the line:

- Better mouse support (reading TTS strings when hovering over objects, "snapping" controls
- HUD Reader Mode
- Text Sizer
- Support for audio stream audio descriptions (as opposed to just TTS)
- Magnifier
- Improved support for high contrast theming (some bugs in current release)
- Keybinding

Additionally, it would be amazing to get the screenreader running in the Editor, to make Godot 4.3+ more accessible to blind and visually impaired users.

[<- Previous (A Player's Guide)](playerguide.md)
 | [Next (Accessibility FAQ) ->](accessibility.md)

[Back to Index](index.md)

[Back to README](../../README.md)
