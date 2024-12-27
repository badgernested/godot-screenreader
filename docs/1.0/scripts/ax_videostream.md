# ax_videostream
Inherits: [VideoStreamPlayer](https://docs.godotengine.org/en/stable/classes/class_videostreamplayer.html)

Script for adding additional accessibility function to VideoStreamPlayer Controls.

## Description

## Constants

### SUBTITLE_FONT
``SUBTITLE_FONT = <Object>``
The font used for subtitles.


## Properties

###  alt_text

| Return Type | Default Value |
|:-------------:|:-------------:|
| ``String`` | ``""``

This Control's alt text.


### audio_description

| Return Type | Default Value |
|:-------------:|:-------------:|
| ``String`` | ``""``

The source VTT formatted .txt file for the video's TTS-generated audio description.

### audio_description_strings

| Return Type | Default Value |
|:-------------:|:-------------:|
| ``Array`` | ``[]``

The array of objects used in audio description.

### draw_highlight
| Return Type | Default Value |
|:-------------:|:-------------:|
| ``bool`` | ``true``

If true, the highlight surrounding the control when it is selected is drawn.

### enable_mouse
| Return Type | Default Value |
|:-------------:|:-------------:|
| ``bool`` | ``false``

If true, this node is set to focus_mode = FOCUS_MODE_CLICK instead of FOCUS_MODE_NONE when the screenreader has loaded this Control.

### ignore
| Return Type | Default Value |
|:-------------:|:-------------:|
| ``bool`` | ``false``

Whether or not this Control is ignored during navigation generation.

### subtitle_font_size

| Return Type | Default Value |
|:-------------:|:-------------:|
| ``subtitle_font_size`` | ``16``

The font size used for subtitles.

### subtitle_strings

| Return Type | Default Value |
|:-------------:|:-------------:|
| ``Array`` | ``[]``

The array of objects used in subtitles.

### subtitles

| Return Type | Default Value |
|:-------------:|:-------------:|
| ``String`` | ``""``

The source VTT formatted .txt file for the video's subtitles.

## Methods

### ax_custom_text()
``String ax_custom_text()``

If this value returns a non-empty value, it will read that string instead of the default string for the screenreader when it reads its name.

### ax_function_override()
``bool ax_function_override()``

When this function returns true, it will override the regular input function of the control. Note that this will require you to manually insert all emit_signal calls.

### ax_screenreader_navigation()
``bool ax_screenreader_navigation()``

If this method returns true, the default screenreader navigation functionality will still be called. Typically if you did some other functionality this frame, you don't want to trigger navigation too. So make this return false if you trigger functionality this frame.

### pause_video()
``void pause_video()``

Pauses the video.

### play_video()
``void play_video()``

Plays the video.

### stop_video()
``void stop_video()``

Stops the video.

[Back to Script Index](../scripts_info.md)

[Back to Index](../index.md)

[Back to README](../../../README.md)
