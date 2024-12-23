extends VideoStreamPlayer

@export var alt_text: String = ""
@export var ignore: bool = false
@export_file("*.txt") var audio_description: String
@export_file("*.txt") var subtitles: String
@export var enable_mouse: bool = false
@export var draw_highlight: bool = true

const SUBTITLE_FONT = preload("res://screenreader/fonts/F25_Bank_Printer.ttf")

var subtitle_font_size = 16

var audio_desc_data = []
var subtitle_data = []

# Text to be displayed as subtitles
var display_text = ""
var base_display_position = Vector2(0,0)
var display_position = Vector2(0,0)
var display_rect = Rect2(0,0,0,0)
@onready var display_size = size.x * 0.75
@onready var initial_size = size

# Text to be read as audio description
var read_text = ""


# If this value returns a non-empty value, it will read that
# string instead of the default string for the screenreader
# when it reads its name.
func ax_custom_text() -> String:
	return ""

# When this function returns true, it will override 
# the regular input function of the control.
# Note that this will require you to manually 
# insert all emit_signal calls.
func ax_function_override():
	return false
	
# If this method returns true, the default screenreader
# navigation functionality will still be called.
# Typically if you did some other functionality this frame,
# you don't want to trigger navigation too. So make this
# return false if you trigger functionality this frame.
func ax_screenreader_navigation():
	return true


func _ready() -> void:
	if audio_description != null:
		audio_desc_data = VTTReader.read(audio_description)
	if subtitles != null:
		subtitle_data = VTTReader.read(subtitles)
		
	base_display_position = Vector2(size.x * 0.5 - display_size * 0.5,
								size.y * 0.93)

func _process(_delta: float) -> void:
	var old_display_text = display_text
	var old_read_text = read_text
	
	display_text = ""
	read_text = ""
	
	# Do subtitles
	if Screenreader.subtitles_enabled:
		for c in subtitle_data:
			# in a subtitle
			if c[0] < stream_position && c[1] > stream_position:
				display_text = c[2]
				var line_count = (display_text.count("\n") + 1)
				
				display_position = base_display_position - Vector2(0, (line_count-2)*(subtitle_font_size)*(1- 1/line_count))
				
				var find_longest = display_text.split("\n")
				
				var longest = ""
				
				for d in find_longest:
					if d.length() > longest.length():
						longest = d
				
				var box_size = SUBTITLE_FONT.get_string_size(
							longest,
							HORIZONTAL_ALIGNMENT_LEFT,
							display_size,
							subtitle_font_size)
							
				display_position.x = (size.x * 0.5) - (box_size.x + subtitle_font_size)*0.5 + 8
				
				display_rect = Rect2((size.x * 0.5) - (box_size.x + subtitle_font_size)*0.5,
									display_position.y - subtitle_font_size - 4,
									box_size.x + subtitle_font_size,
									box_size.y + subtitle_font_size * (line_count-1))
	
	# Only read audio captions when focused
	if Screenreader._is_cooled_down() && Screenreader._OS_focused:
		if Screenreader.audio_description_enabled:
			if Screenreader.focused == self:
				if !paused && is_playing():
					for c in audio_desc_data:
						# in a subtitle
						if c[0] < stream_position && c[1] > stream_position:
							read_text = c[2]
							
							if read_text != old_read_text && !read_text.is_empty():
								TTS.speak(read_text)
				
	
	# updates display text if changes
	if display_text != old_display_text:
		queue_redraw()
			
func _draw():
	if !display_text.is_empty():
		draw_rect(display_rect, Color.BLACK, true)
		draw_multiline_string(SUBTITLE_FONT, display_position, display_text, HORIZONTAL_ALIGNMENT_LEFT, display_size, subtitle_font_size)

func play_video():
	read_text = ""
	paused = false
	if !is_playing():
		play()
		
	Screenreader._tts_speak_direct(Screenreader.VIDEO_NAVIGATION_STRINGS["PLAY"])
	
func stop_video():
	TTS.stop()
	stop()
	
	Screenreader._tts_speak_direct(Screenreader.VIDEO_NAVIGATION_STRINGS["STOPPED"])
	
func pause_video():
	TTS.stop()
	paused = true
	
	Screenreader._tts_speak_direct(Screenreader.VIDEO_NAVIGATION_STRINGS["PAUSED"])
	
