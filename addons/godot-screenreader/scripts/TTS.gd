###############################################
# TTS
#
# Text-to-Speech Interface.
# Originally written by LightsOutGames for
# Godot 3.x, updated to Godot 4.x by rodolpheh.
# 
# Both licensed under MIT License.
###############################################
extends Object
class_name TTS
## The TTS controller.
##
## This object controls the Text-to-Speech (TTS) interface
## used by the screenreader. This object can be used to
## call TTS whenever you want.

## This is the default language code for the TTS to use.
static var default_lang: String = "en"

## This is the voice ID of the current speaker.
static var voice_id: String = ""

## Reads the current [param sentence] with TTS. If [param interrupt] is true,
## currently speaking text will be interrupted. 
static func speak(sentence: String, interrupt: bool = false,
		language: String = default_lang, pitch: float = 1.0,
		rate: float = 1.0, volume: int = 50) -> void:
	if voice_id == "":
		voice_id = DisplayServer.tts_get_voices_for_language(language)[0]
	if interrupt:
		DisplayServer.tts_stop()
		
	DisplayServer.tts_speak(sentence, voice_id, volume, pitch, rate)

## Stops the TTS speaking.
static func stop() -> void:
	DisplayServer.tts_stop()

## Sets the speaking rate. Or, that would be what it would do, if it 
## had any functionality...
## @experimental
static func _set_rate(new_rate : float) -> void:
	print("Asking to change rate")
