extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"

func _ready():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("display", "resolution", 0)
		config.set_value("display", "window_mode", 0)
		config.set_value("display", "vsync", true)
		config.set_value("display", "fxaa", Viewport.SCREEN_SPACE_AA_DISABLED)
		config.set_value("display", "msaa", Viewport.MSAA_DISABLED)
		config.set_value("display", "framerate", 5)
		
		config.set_value("audio", "master_volume", 0.50)
		config.set_value("audio", "music_volume", 0.50)
		config.set_value("audio", "sfx_volume", 0.50)
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)

func save_display_settings(key: String, value):
	config.set_value("display", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_display_settings():
	var display_settings = {}
	for key in config.get_section_keys("display"):
		display_settings[key] = config.get_value("display", key)
	return display_settings
	
func save_audio_settings(key: String, value):
	config.set_value("audio", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_audio_settings():
	var audio_settings = {}
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	return audio_settings
