# Installation

- [Installation](#installation)
  * [Start with Template](#start-with-template)
  * [Add to Your Project](#add-to-your-project)
    + [Copy the Files](#copy-the-files)
    + [Set Up the Inputs](#set-up-the-inputs)
    + [Globals](#globals)

There are two ways to install ``godot-screenreader`` to your project, and it depends on if you have started working on your project yet. If you are starting with a fresh new project, it is recommended to use the template provided in this repository. However, if you have already started development on your project, you can make modifications to your project to support ``godot-screenreader.``

## Start with Template

First, clone the repository to an empty directory with the following command:

```
git clone git@github.com:badgernested/godot-screenreader.git
```

Then, open Godot 4.3+ and import the project's ``project.godot' file. Open the project.

You will notice that there are several import errors. This is not a problem with the project itself but is caused by how Godot loads resources. Immediately close the project without interacting with anything and re-open it again. The errors will be gone, and you can fix other import warnings by simply opening the .tscn files in the error messages.

> [!CAUTION]
> It is very important that you do not interact with anything before closing the project in this step, or else certain theme assets will not load properly and you will need to re-create the template.

Now, godot-screenreader is ready for your new project. It is recommended to remove the ``exports``, ``examples`` and ``docs`` directories, since these are not necessary for the running of the screenreader. However, ``examples`` does include samples to help you learn examples of how to best develop interfaces for the screenreader.

## Add to Your Project

If you have an already existing project, you can add godot-screenreader to it.

### Copy the Files

First, clone the repository to an empty directory with the following command:

```
git clone git@github.com:badgernested/godot-screenreader.git
```

Copy all of the files in ``/screenreader`` into the root directory of your Godot project.

### Set Up the Inputs

godot-screenreader uses unique input names to distinguish itself from normal UI control. You may override these controls with the following Inputs:

| Input        | Default           | Summary  |
|:-------------:|:-------------:|:-----:|
| ``DOM_screenreader_enable`` | F2 | Enables the screenreader. |
| ``DOM_screenreader_menu`` | F5 | Opens the screenreader menu. |
| ``DOM_read_item`` | F3 | Reads the description text of the currently selected control. |
| ``DOM_stop_talk`` | F4 | Stops the TTS voice talking. |
| ``DOM_prev`` | Shift + Tab | Navigates to the previous tabable control or area. |
| ``DOM_next`` | Tab | Navigates to the next tabable control or area. |
| ``DOM_up`` | Up | Navigates to the next visible selectable control. |
| ``DOM_down`` | Down | Navigates to the previous visible selectable control. |
| ``DOM_item_decrement`` | Left | Navigates to the previous item within a selected control. |
| ``DOM_item_increment`` | Right | Navigates to the next item within a selected control. |
| ``DOM_select`` | Enter | Selects an item within a selected control. |
| ``DOM_update`` | Space | Updates the value of some controls, like checkboxes. |
| ``DOM_cancel`` | Escape | Cancels a selection within a selected control. |

### Globals

While not necessary, it is useful to assign ``AXController`` as a Global Autoload. The rest of this documentation is written assuming that you have added ``AXController`` to the Autoload list.

[<- Previous (Accessibility FAQ)](accessibility.md)
 | [Next (General Usage) ->](generaluse.md)

[Back to Index](index.md)

[Back to README](../../README.md)
