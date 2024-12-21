extends Node
class_name TTS

# Update this to update the default lang for your game
static var default_lang = "en"

static var normal_rate : float = 1.0

static var voice_id = null

static func speak(sentence, interrupt = false, language=default_lang, pitch=1.0, rate=1.0, volume=50):
	print(sentence)

	if voice_id == null:
		voice_id = DisplayServer.tts_get_voices_for_language(language)[0]
	if interrupt:
		DisplayServer.tts_stop()
		
	DisplayServer.tts_speak(sentence, voice_id, volume, pitch, rate)

static func stop():
	DisplayServer.tts_stop()

static func _set_rate(new_rate : float):
	print("Asking to change rate")

static func singular_or_plural(count, singular, plural):
	if count == 1:
		return singular
	else:
		return plural

static func can_ssml():
	return true
