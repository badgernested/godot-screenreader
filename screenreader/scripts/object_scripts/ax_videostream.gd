extends VideoStreamPlayer
## Script for adding additional accessibility function to VideoStreamPlayer Controls.
##
## This script is designed to extend functionality for the VideoStreamPlayer Control
## to godot-screenreader. Extend this script to add additional functionality
## such as custom screenreader text and input.

## This Control's alt text.
@export var alt_text: String = ""
## Whether or not this Control is ignored during navigation generation.
@export var ignore: bool = false
## If true, this node is set to [param focus_mode] = [param FOCUS_MODE_CLICK]
## instead of [param FOCUS_MODE_NONE] when the screenreader has loaded this Control.
@export var enable_mouse: bool = false
## If true, the highlight surrounding the control when it is selected is drawn.
@export var draw_highlight: bool = true
## The source VTT formatted [param .txt] file for the video's TTS-generated audio description.
@export_file("*.txt") var audio_description: String
## The source VTT formatted [param .txt] file for the video's subtitles.
@export_file("*.txt") var subtitles: String

## The font used for subtitles.
const SUBTITLE_FONT: FontFile = preload("res://screenreader/fonts/F25_Bank_Printer.ttf")

## The font size used for subtitles.
var subtitle_font_size: int = 16

## The array of objects used in audio description.
var audio_description_strings: Array = []
## The array of objects used in subtitles.
var subtitle_strings: Array = []

var _display_text: String = ""
var _base_display_position: Vector2 = Vector2(0,0)
var _display_position: Vector2 = Vector2(0,0)
var _display_rect: Rect2 = Rect2(0,0,0,0)
@onready var _display_size: float = size.x * 0.75

## Text to be read as audio description.
var _read_text: String = ""


## If this value returns a non-empty value, it will read that
## string instead of the default string for the screenreader
## when it reads its name.
func ax_custom_text() -> String:
	return ""

## When this function returns true, it will override 
## the regular input function of the control.
## Note that this will require you to manually 
## insert all emit_signal calls.
func ax_function_override() -> bool:
	return false
	
## If this method returns true, the default screenreader
## navigation functionality will still be called.
## Typically if you did some other functionality this frame,
## you don't want to trigger navigation too. So make this
## return false if you trigger functionality this frame.
func ax_screenreader_navigation() -> bool:
	return true


func _ready() -> void:
	if audio_description != null:
		audio_description_strings = VTTReader.read(audio_description)
	if subtitles != null:
		subtitle_strings = VTTReader.read(subtitles)
		
	_base_display_position = Vector2(size.x * 0.5 - _display_size * 0.5,
								size.y * 0.93)

func _process(_delta: float) -> void:
	var old__display_text = _display_text
	var old_read_text = _read_text
	
	_display_text = ""
	_read_text = ""
	
	# Do subtitles
	if Screenreader.subtitles_enabled:
		for c in subtitle_strings:
			# in a subtitle
			if c[0] < stream_position && c[1] > stream_position:
				_display_text = c[2]
				var line_count = (_display_text.count("\n") + 1)
				
				_display_position = _base_display_position - Vector2(0, (line_count-2)*(subtitle_font_size)*(1- 1/line_count))
				
				var find_longest = _display_text.split("\n")
				
				var longest = ""
				
				for d in find_longest:
					if d.length() > longest.length():
						longest = d
				
				var box_size = SUBTITLE_FONT.get_string_size(
							longest,
							HORIZONTAL_ALIGNMENT_LEFT,
							_display_size,
							subtitle_font_size)
							
				_display_position.x = (size.x * 0.5) - (box_size.x + subtitle_font_size)*0.5 + 8
				
				_display_rect = Rect2((size.x * 0.5) - (box_size.x + subtitle_font_size)*0.5,
									_display_position.y - subtitle_font_size - 4,
									box_size.x + subtitle_font_size,
									box_size.y + subtitle_font_size * (line_count-1))
	
	# Only read audio captions when focused
	if Screenreader._is_cooled_down() && Screenreader._OS_focused:
		if Screenreader.audio_description_enabled:
			if Screenreader.focused == self:
				if !paused && is_playing():
					for c in audio_description_strings:
						# in a subtitle
						if c[0] < stream_position && c[1] > stream_position:
							_read_text = c[2]
							
							if _read_text != old_read_text && !_read_text.is_empty():
								TTS.speak(_read_text)
				
	
	# updates display text if changes
	if _display_text != old__display_text:
		queue_redraw()
			
func _draw():
	if !_display_text.is_empty():
		draw_rect(_display_rect, Color.BLACK, true)
		draw_multiline_string(SUBTITLE_FONT, _display_position, _display_text, HORIZONTAL_ALIGNMENT_LEFT, _display_size, subtitle_font_size)

## Plays the video.
func play_video() -> void:
	_read_text = ""
	paused = false
	if !is_playing():
		play()
		
	Screenreader._tts_speak_direct(Screenreader._VIDEO_NAVIGATION_STRINGS["PLAY"])
	
## Stops the video.
func stop_video() -> void:
	TTS.stop()
	stop()
	
	Screenreader._tts_speak_direct(Screenreader._VIDEO_NAVIGATION_STRINGS["STOPPED"])
	
## Pauses the video.
func pause_video() -> void:
	TTS.stop()
	paused = true
	
	Screenreader._tts_speak_direct(Screenreader._VIDEO_NAVIGATION_STRINGS["PAUSED"])
	
