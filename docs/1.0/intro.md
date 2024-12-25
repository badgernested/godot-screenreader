# Introduction

godot-screenreader is an asset/tool that you can add on to your Godot projects to install a screenreader for navigating Control nodes. A screenreader allows for improved accessibility of menu controls so that blind or visually impaired users, among others, can better tell what is on the screen.

## Technical Details

godot-screenreader is designed to work on versions of Godot 4.3+. If you need a screenreader or Text-to-Speech (TTS) functionality for Godot 3.x, consider using [godot-tts](https://github.com/lightsoutgames/godot-tts) by [LightsOutGames](https://www.lightsout.games/) instead.

Currently, godot-screenreader is confirmed to work on Windows and Linux platforms.

godot-screenreader has not yet been tested with braille displays. 

## Why Accessibility?

Accessibility is a design philosophy that emphasizes many different kinds of users for your product. This includes disabled users, such as people with sensory, motor or mental disabilities; but this also includes users in environments where some hardware functionality may not be available, such as in loud settings, settings with high glare, poor quality hardware or disfunctional hardware. The idea is that there should be many ways to be able to achieve the same goal, with all the tools and information you need readily available to do it, so that interference with completing a task is put to a minimum.

For a video game, this may include improving sound design in your gameplay, adding keybinding capabilities, incorporating notes, guides and tutorials into your game loop, and designing multiple input/output modes. This screenreader improves accessibility by providing a consistent way to navigate UI Controls in the SceneTree.

> [!IMPORTANT]  
> Simply installing a screenreader does not mean that your game is instantly usable for blind or visually impaired players. The screenreader only provides the ability to navigate Control elements reliably in a game. Other elements will need to be developed independently. In some circumstances, a screenreader is not an appopriate solution. Think carefully about how different kinds of users will interact with your game. Always remember to make sure you test with disabled players before claiming any game is accessible.

> [!WARNING]  
> For liability purposes, do not ever claim your software can prevent or mitigate certain medical interactions, such as those relating with epilepsy, or that it has any ability to treat or cure any medical condition.

### Doesn't Accessibility Hurt My Game Design?

Outside of rare edge cases, accessibility in video games does not harm your game design. This is a misconception spread by not understanding what things should be made accessible. 

For example, reviewing [web accessibility guidelines](https://www.w3.org/TR/WCAG22/), which are designed more for businesses rather than gaming or storytelling, shows us that most of the requirements can be organized into a few simple categories:
- Design choices that encourage a sane design that can be accessed in multiple ways
- Edge case scenarios that should be avoided for difficulty of use/danger to users
- In some rare cases, additional modes of specialized interaction to improve user experience, such as sign-language interpreters

Having the ability to change themes to be more readable, have important items highlighted on the screen or to have buttons more easy to find or control are all things that in an overwhelming number of games can be improved in simple ways to make the experience more open to those with disabilities, those playing with incomplete or nonfunctioning hardware or other needs.

There are some rare cases where an accessibility solution might conflict with game design. For example, a game may require finding hidden items, but the ability to select items on a screen removes the challenge. This kind of situation should be seen not as a threat, but as a design challenge. What other ways could you communicate to different kinds of users ways to find hidden items in your interface?

Ultimately, it is okay if some problems can't be solved - especially as small, independent game developers - but fixing problems that have been largely solved, such as navigating basic interfaces, or improving visibility, is still incredibly important. After all, some users may need some help with navigating menus or seeing bigger text, but can enjoy the challenge of these segments.

> [!IMPORTANT]  
> Making your game more accessible not only improves usability for highly visible groups such as blind or deaf users, but also users with less pronounced disabilities or complex situations that you could not otherwise predict. Remember: Bad UI usability is not the flex you think it is!

Additionally, making your games more accessible actually improves your game design and programming practices by encouraging better design choices that focus more on the functionality of your software rather than just surface level behavior and looks. This makes your game user interfaces easier to debug and easier to maintain on large-scale projects.

For many, the real concern with developing accessible games is the time it consumes to create accessible interfaces. The goal of building this screenreader was to make an open-source, easy to install and use for developers means of improving accessibility within a popular open-source game engine.

## What is a Screenreader?

A screenreader is a special piece of technology that allows users to navigate interactable or readable elements on a screen, such as labels, buttons, textboxes and other assorted features without the use of a screen, through audio or braille output.

Popular Windows screenreaders include [JAWS by Freedom Scientific](https://www.freedomscientific.com/products/software/jaws/) and the free and open-source [NVDA](https://www.nvaccess.org/download/). On Linux, programs such as Orca are used.

While compatibility with the screenreader is desirable in most applications, because of the nature of video game user interfaces, it makes more sense to have a customizable screenreader embedded into the game itself, since video game user interfaces are far more diverse than those seen in most web or desktop applications. This allows for the game to integrate itself closely with the screenreader itself.

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
- Text Sizer
- Support for audio stream audio descriptions (as opposed to just TTS)
- Magnifier
- Improved support for high contrast theming (some bugs in current release)
- Keybinding

Additionally, it would be amazing to get the screenreader running in the Editor, to make Godot 4.3+ more accessible to blind and visually impaired users.

[<- Previous (A Player's Guide)](playerguide.md)
 | [Next (Installation) ->](installation.md)

[Back to README](../../README.md)
