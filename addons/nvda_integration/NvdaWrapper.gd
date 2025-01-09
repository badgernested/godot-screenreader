class_name NvdaWrapper
extends Object
## The NVDA Wrapper class.
##
## This class allows direct access to NVDA screenreader,
## which is a Windows-based screenreader.
##
## Original work by NightBlade (https://github.com/nightblade9/godot-nvda-integration)
## Note: This integration removes any fallbacks to DisplayDriver.tts functions.

## Sets the voice for built-in TTS. Feel free to set it when you update options.
static var voice:String

## I'm keeping this in here, so that users can init the voices first.
## However, this way users are not required to add an autoload
static func init_nvda():
	_load_voices()

## Say something using NVDA!
static func speak(text:String, lang=TTS.default_lang) -> void:
	if voice == null || lang == "":
		_load_voices(lang)
		
	stop()
	if is_using_nvda():
		print("NVDA text: " + text)
		NVDA.speak_text(text)

## Stops all speech.
static func stop():
	if is_using_nvda():
		NVDA.cancel()

## Checks if the current user is using NVDA.
static func is_using_nvda():
	return NVDA.is_running()

## Loads the current voice to speak with.
static func _load_voices(lang=TTS.default_lang):
	if voice == null:
		
		var voices = DisplayServer.tts_get_voices_for_language(lang)
		
		if len(voices) > 0:
			voice = voices[0] # pick the first. Just 'cuz.
