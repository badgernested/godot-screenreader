# Using Scripts

You can use godot-screenreader without using scripts, but attaching scripts to certain nodes can greatly enhance the usability of your user experience.

To attach a script, simply drag the script associated with the type of Control you're attaching it to from the ``res://screenreader/scripts/object_scripts/`` directory.

> [!IMPORTANT]  
> Make sure you use the script that extends the Control type that you are attaching your script to, or else you will have errors.

Once you attach the script, new options will be available to you in the editor, to further tweak how a Control interacts with the screenreader.

## Extended Properties

### Alt Text

If Alt Text is populated, when a screenreader user navigates to this Control, additional or replacement text will be read. The way Alt Text is read to the player is different for each Control type:

| Control        | Alt Text Function  |
|:-------------:|:-------------:|
| Label | Reads alt text instead of original text. |
| RichTextLabel | Reads alt text instead of original text. |
| MenuBar | Reads alt text after menu selected number. |
| Button | Reads alt text instead of original text. |
| LinkButton | Reads alt text instead of original text. |
| CheckBox | Reads alt text instead of original text. |
| CheckButton | Reads alt text instead of original text. |
| MenuButton | Reads alt text instead of original text. |
| OptionButton | Reads alt text after selection text. |
| LineEdit | Reads alt text after text in textbox. |
| TextEdit | Reads alt text after text in textbox. |
| CodeEdit | Reads alt text after text on current line in textbox. |
| ProgressBar | Reads alt text after reading the value of the Control. |
| SpinBox | Reads alt text after reading the value of the Control. |
| HSlider | Reads alt text after reading the value of the Control. |
| VSlider | Reads alt text after reading the value of the Control. |
| TextureRect | Requires alt text to be recognized by screenreader. Reads alt text before indicating it is an image. |
| VideoStreamPlayer | Reads alt text before reading "VideoStreamPlayer". If no alt text, it will read the node's name as listed in the editor. |
| Tree | Reads alt text after selected tree node information. |

### Ignoring Nodes

If Ignore is checked, this node will be ignored when building the navigation tree for godot-screenreader.

This is useful in situations where you may want the screenreader to skip over certain Controls. For example, consider an options menu, where each option is represented visually with a Label and CheckButton node. It makes more sense to ignore the Label nodes and use alt text on the CheckButton nodes so that the screenreader user has to navigate through fewer elements to reach the button.

### Enable Mouse

By default, when the screenreader is enabled and starts navigating the loaded Controls, all Controls will have their ``focus_mode`` set to ``FOCUS_MODE_NONE``. This can interfere with some mouse functionality that may still be desirable. To set it to ``FOCUS_MODE_CLICK`` instead, make sure Enable Mouse is checked.

### Draw Highlight

By default, a highlight surrounding the selected Control is drawn on screen to help show users what Control is selected visually. If you don't want this highlight to appear, Draw Highlight should be unchecked.

### Node Grouping

If a Control node, or a select few Panel nodes, has Focus Marked Container checked, the children of this node are grouped together for navigating with "Next" and "Previous keys. This way, you can use Control nodes to organize your UI so that the screenreader can easily and quickly navigate between important areas of your user interface.

### Custom Controls

In Godot, it is common to create custom Controls using scenes with a Control node as the root node. If this root node is given a script that extends ``ax_control.gd``, it can check Custom Control and have the entire Control be treated as one object, instead of adding each of the child Controls.

### Read Fraction

If checked, Read Fraction reads the value of this Control as a fraction of the current value relative to the max value.

### Read Percent

If checked, Read Percent reads the value of this Control as a percent of the current value relative to the max value.

### Read Value

If checked, Read Value reads the value of this Control as pure values.

## Cooldown

How frequently the Control updates when the decrement/increment keys are held. If set to 0.0, it will update every frame.

### Audio Description

This leads to the path of the VTT formatted ``.txt`` file that contains the audio description for the TTS to read when the Control is selected, if audio description is enabled.

### Subtitles

This leads to the path of the VTT formatted ``.txt`` file that contains the subtitles track to be displayed over the video, if subtitles are enabled.

[<- Previous (Usage Summary)](usage_summary.md)
 | [Next (Extending Scripts) ->](extending_scripts.md)

[Back to Index](index.md)

[Back to README](../../README.md)
