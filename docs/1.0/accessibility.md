# Accessibility FAQ

- [Accessibility FAQ](#accessibility-faq)
  * [Why Accessibility?](#why-accessibility)
    + [Doesn't Accessibility Hurt My Game Design?](#doesn-t-accessibility-hurt-my-game-design)
  * [What is a Screenreader?](#what-is-a-screenreader-)
    + [When Might a Screenreader Not Be Appropriate for My Game?](#when-might-a-screenreader-not-be-appropriate-for-my-game)
  * [Why is Native Screenreader Support Not Included?](#why-is-native-screenreader-support-not-included)

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

While compatibility with the screenreader is desirable in most applications, because of the nature of how Godot's user interface elements are designed, it makes more sense to have a customizable screenreader embedded into the game itself, since video game user interfaces are far more diverse than those seen in most web or desktop applications. This allows for the game to integrate itself closely with the screenreader itself.

### When Might a Screenreader Not Be Appropriate for My Game?

A screenreader is a very useful tool for making certain user interfaces a lot easier to use for blind or visually impaired users, or users who just need content read out to them and reliably selectable. However, because games have a lot of diverse applications, its important to consider what applications a screenreader is not ideal for. Here are a few disadvantages to consider for your projects:

- The screenreader is only useful for navigating Controls like labels, buttons and text boxes. As a result, its usefulness is limited to user interfaces that work more like menus or web pages. For HUDs, a screenreader's usefulness depends on if the current gameplay can be interrupted. In turn-based games, for example, a screenreader is appropriate because actions do not occur until user input is received, so a screenreader can allow a user to more easily navigate the interface. HUDs in real time games should instead use a means of readily reading text off of the interface without requiring navigation to this text.
- godot-accessibility screenreader can be slow when making TTS calls to the OS. This is an unavoidable problem that occurs in any software using the OS's native TTS. This means that TTS should not be relied upon for any important timing-based cue, since there will sometimes be a noticable delay with TTS. In these cases, a pre-recorded sound cue, or one generated by programs like [eSpeak](https://espeak.sourceforge.net/) would be better.
- A screenreader like godot-accessibility overrides the default navigation scheme presented by the developer. In some edge cases, it is not appropriate for a screenreader to override this navigation scheme. For these cases, navigation for these specialized users should be built manually.

## Why is Native Screenreader Support Not Included?

It might seem odd to web developers or other kinds of application developers why a native screenreader in Godot is a better option than using a native screenreader. This is for a few reasons:

- UI design in game development in general is more open ended than it is in most DOM-based applications. Instead, the developer needs more curated control to balance gameplay with accessibility. Because video game UI is constructed from the ground up, the game itself should have more control over how this works, and it is easier to implement if it is part of the game's code as opposed to a special plugin. Here are a few cases where it would be inappropriate for a screenreader to simply assume Godot Control elements are part of a typical interface:
    - HUD elements, such as labels or power bars, on a real time game
    - Hidden button elements representing hidden items to select
    - Custom created UI elements, or UI elements built of composite elements
- Many game developers, especially indie game developers, would be opposed to being forced to build their user interfaces in a HTML compatible or DOM-element format, due to the restrictions that it places on designing user interfaces. This can be hard to imagine in an application or web based development environment, but video games rely heavily on the creation of unique user interface elements. Oftentimes developers design user interfaces with no object model whatsoever, simply because its easier to understand. There needs to be more fine-tuned control to developers that DOM-based models cannot provide alone. Additionally, games should be a place where new kinds of user interfaces can be safely explored without being forced into the confines of a hierarchical markup language.
-  This asset was developed to satisfy a few needs outside of accessibility:
    - This asset needs to be easy to install and set up, so the base asset should try to use as much native Godot 4.x functionality as possible. 
    - This asset needs to be built in such a way where all its functionality can be self contained so its easier to distribute as a potential future editor plugin.
    - This asset needs to work within the confines of the expectations of Godot 4.x users and the way they typically use and interact with UI elements when building games.
- The immediate value of being able to have a tool that provides some basic accessibility to Godot game user interfaces outweighs the time it would take to solve these problems in screenreaders natively.

There is, however, real value in integrating some screenreader support in the future. Open source screenreaders like NVDA support custom user settings that could be used when strings are read. It may even be possible to simulate a DOM model to pass to the screenreader in some cases in a future development.

> [!IMPORTANT]  
> A concern for some screenreader support is licensing, because this is a free and open source project. Please do not contribute any code changes that might violate any commercial licenses. Code changes that interact with third-party software will be analyzed for possible license conflicts.

Additionally, it would be amazing to get the screenreader running in the Editor, to make Godot 4.3+ more accessible to blind and visually impaired users.

[<- Previous (Introduction)](intro.md)
 | [Next (Installation) ->](installation.md)

[Back to Index](index.md)

[Back to README](../../README.md)
