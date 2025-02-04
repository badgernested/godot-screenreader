class_name NvdaWrapper
extends Object
## This class acts as a wrapper class for NVDA.
##
## It will allow for direct NVDA access, and can fall back to
## OS level TTS function if NVDA is not available.

## Constants

## The default language used for reading.
const DEFAULT_LANGUAGE = "en-GB"

## The default voice used for reading.
const DEFAULT_VOICE = 0

## Properties

## Stores the current language ID.
## Defaults to English.
static var language:String = DEFAULT_LANGUAGE

## The currently loaded voice.
static var voice:String = ""

## Methods

## Initializes the voices. 
## Voices will be initialized when first speaking,
## but this allows for a developer to initialize
## voices independently.
static func init_voices(_language: String = DEFAULT_LANGUAGE):
	_load_voices(_language)

## Speaks using NVDA only.
## If NVDA is not detected, the method returns.
static func say_nvda(text: String, _language: String = "", _speed: float = 1.0) -> bool:
	if !is_using_nvda():
		return false
	
	# If no text is passed, ignore attempting to read.
	if text.strip_edges().is_empty():
		printerr("No text passed to speak.")
		return false
	
	# Ends current speech.
	NVDA.cancel()
	
	# Only uses modifier if it is detected.
	if !_language.is_empty() || _speed != 1.0:
		NVDA.speak_text_modifier(text, _language, _speed)
	else:
		NVDA.speak_text(text)
	
	return true

## Speaks using NVDA, if available.
## If NVDA is not available, will fallback to DisplayServer.tts.
static func say(text:String, _language: String = "", _speed: float = 1.0) -> void:
	
	# If no text is passed, ignore attempting to read.
	if text.strip_edges().is_empty():
		printerr("No text passed to speak.")
		return
	
	# Grabs voices if no voice detected, or language 
	if language != _language && !_language.is_empty():
		_load_voices(_language)
	# Uses the default language if no language is defined.
	elif language != DEFAULT_LANGUAGE:
		_load_voices(DEFAULT_LANGUAGE)
		
	# If no voice loaded, load default
	if voice.is_empty():
		_load_voices()
		
	# Stops current speech.
	stop()
	
	# Starts speaking.
	# Tries to use NVDA by default, but if it fails,
	# will fallback to OS TTS.
	if !say_nvda(text, _language, _speed):
		# If a voice is not set by loading voices, print an error.
		if voice.is_empty():
			printerr("No voice is available with language %s." % _language)
			return
		
		# Constrains speed range.
		if _speed > 1.0:
			_speed = 1.0
		if _speed < 0.5:
			_speed = 0.5
		
		DisplayServer.tts_speak(text, voice, 50, 1.0, _speed)

## Stops all speech.
static func stop():
	if is_using_nvda():
		NVDA.cancel()
	else:
		DisplayServer.tts_stop()

## Checks if NVDA is available.
static func is_using_nvda():
	if OS.get_name() == "Windows":
		return NVDA.is_running()
		
	return false

## Loads available voice.
## Only used for DisplayServer.
static func _load_voices(_language: String = DEFAULT_LANGUAGE):
	voice = ""
	language = DEFAULT_LANGUAGE
	
	var voices;
	
	# Get voice based on the the OS.
	match OS.get_name():
		"Windows":
			# Gets the first part of the language string
			voices = DisplayServer.tts_get_voices_for_language(_language.split("-")[0])
		"Linux":
			# Uses the whole language-locale string
			voices = DisplayServer.tts_get_voices_for_language(_language)
	
	# If voices are empty, print an error and return.
	if voices.is_empty():
		printerr("No voices found for language %s" % _language)
		return
		
	voice = voices[0]
	language = _language
