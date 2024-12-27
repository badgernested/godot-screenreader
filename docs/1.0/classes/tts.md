# TTS
Inherits: [Object](https://docs.godotengine.org/en/stable/classes/class_object.html)

The TTS controller.

## Description

This object controls the Text-to-Speech (TTS) interface used by the screenreader. This object can be used to call TTS whenever you want.

## Properties


### default_lang

| Return Type | Default Value |
|:-------------:|:-------------:|
| ``String`` | ``"en"``

This is the default language code for the TTS to use.


### voice_id

| Return Type | Default Value |
|:-------------:|:-------------:|
| ``String`` | ``""``

This is the voice ID of the current speaker.


## Methods

### speak()

``void speak(sentence: String, interrupt: bool = false, language: String = default_lang, pitch: float = 1.0, rate: float = 1.0, volume: int = 50) static``

Reads the current sentence with TTS. If interrupt is true, currently speaking text will be interrupted.


### stop()

``void stop() static``

Stops the TTS speaking.
