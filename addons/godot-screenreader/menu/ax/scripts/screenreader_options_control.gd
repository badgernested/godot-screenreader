extends Control

var parent = null

var options_start = {
	"sfx_enabled" : Screenreader.sfx_enabled,
	"wrap_nav" : Screenreader.navigation_wrap,
	"verbose" : Screenreader.verbose,
	"theme" : HCController.theme_style,
	"subtitles" : Screenreader.subtitles_enabled,
	"adtts" : Screenreader.audio_description_enabled,
}

var options_set = {
	"sfx_enabled" : Screenreader.sfx_enabled,
	"wrap_nav" : Screenreader.navigation_wrap,
	"verbose" : Screenreader.verbose,
	"theme" : HCController.theme_style,
	"subtitles" : Screenreader.subtitles_enabled,
	"adtts" : Screenreader.audio_description_enabled,
}

const CONTRAST_THEMES = [
	"none",
	"hc_dark",
	"hc_light",
]

func _ready() -> void:
	if is_instance_valid($Screenreader/VBoxContainer/SFX_ENABLED/VBoxContainer/SFX_ENABLED):
		$Screenreader/VBoxContainer/SFX_ENABLED/VBoxContainer/SFX_ENABLED.button_pressed = Screenreader.sfx_enabled
	if is_instance_valid($Screenreader/VBoxContainer/WRAP_NAVIGATION/VBoxContainer/WRAP_NAVIGATION):
		$Screenreader/VBoxContainer/WRAP_NAVIGATION/VBoxContainer/WRAP_NAVIGATION.button_pressed = Screenreader.navigation_wrap
	if is_instance_valid($Screenreader/VBoxContainer/VERBOSE/VBoxContainer/VERBOSE):
		$Screenreader/VBoxContainer/VERBOSE/VBoxContainer/VERBOSE.button_pressed = Screenreader.verbose
	
	if is_instance_valid($Screenreader/VBoxContainer/SUBTITLES/VBoxContainer/SUBTITLES):
		$Screenreader/VBoxContainer/SUBTITLES/VBoxContainer/SUBTITLES.button_pressed = Screenreader.subtitles_enabled
	
	if is_instance_valid($Screenreader/VBoxContainer/ADTTS/VBoxContainer/ADTTS):
		$Screenreader/VBoxContainer/ADTTS/VBoxContainer/ADTTS.button_pressed = Screenreader.audio_description_enabled
	
	
	var index = 0
	
	index = CONTRAST_THEMES.find(HCController.theme_style)
	
	$Screenreader/VBoxContainer/THEME/VBoxContainer/THEME.select(index)

func do_ok():
	set_option(options_set)
	
func do_cancel():
	set_option(options_start)

func set_option(options:Dictionary):
	Screenreader.sfx_enabled = options["sfx_enabled"]
	Screenreader.navigation_wrap = options["wrap_nav"]
	Screenreader.verbose = options["verbose"]
	HCController.theme_style = options["theme"]
	
	Screenreader.subtitles_enabled = options["subtitles"]
	Screenreader.audio_description_enabled = options["adtts"]
	
	HCController.set_theme()
	
	if parent != null:
		parent.init()
	

func _on_SFX_ENABLED_toggled(toggled_on: bool) -> void:
	options_set["sfx_enabled"] = $Screenreader/VBoxContainer/SFX_ENABLED/VBoxContainer/SFX_ENABLED.is_pressed()
	set_option(options_set)


func _on_wrap_navigation_toggled(toggled_on: bool) -> void:
	options_set["wrap_nav"] = $Screenreader/VBoxContainer/WRAP_NAVIGATION/VBoxContainer/WRAP_NAVIGATION.is_pressed()
	set_option(options_set)


func _on_verbose_toggled(toggled_on: bool) -> void:
	options_set["verbose"] = $Screenreader/VBoxContainer/VERBOSE/VBoxContainer/VERBOSE.is_pressed()
	set_option(options_set)

func _on_theme_item_selected(index: int) -> void:
	if index < 0:
		index = 0	
	
	options_set["theme"] = CONTRAST_THEMES[index]
	set_option(options_set)


func _on_subtitles_toggled(toggled_on: bool) -> void:
	options_set["subtitles"] = $Screenreader/VBoxContainer/SUBTITLES/VBoxContainer/SUBTITLES.is_pressed()
	set_option(options_set)


func _on_adtts_toggled(toggled_on: bool) -> void:
	options_set["adtts"] = $Screenreader/VBoxContainer/ADTTS/VBoxContainer/ADTTS.is_pressed()
	set_option(options_set)
