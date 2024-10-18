extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"

func _ready():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		create_default_settings()
	else:
		var err = config.load(SETTINGS_FILE_PATH)
		if err != OK:
			printerr("Failed to load settings file. Error code: ", err)
			create_default_settings()
		else:
			ensure_sections_exist()

func create_default_settings():
	create_default_display_settings()
	create_default_audio_settings()

	var err = config.save(SETTINGS_FILE_PATH)
	if err != OK:
		printerr("Failed to save default settings. Error code: ", err)

func ensure_sections_exist():
	if !config.has_section("display"):
		create_default_display_settings()
	if !config.has_section("audio"):
		create_default_audio_settings()
	config.save(SETTINGS_FILE_PATH)

func create_default_display_settings():
	config.set_value("display", "resolution", 0)
	config.set_value("display", "window_mode", 0)
	config.set_value("display", "vsync", true)
	config.set_value("display", "fxaa", Viewport.SCREEN_SPACE_AA_DISABLED)
	config.set_value("display", "msaa", Viewport.MSAA_DISABLED)
	config.set_value("display", "framerate", 5)

func create_default_audio_settings():
	config.set_value("audio", "master_volume", 0.50)
	config.set_value("audio", "music_volume", 0.50)
	config.set_value("audio", "sfx_volume", 0.50)

func save_display_settings(key: String, value):
	config.set_value("display", key, value)
	var err = config.save(SETTINGS_FILE_PATH)
	if err != OK:
		printerr("Failed to save display settings. Error code: ", err)

func load_display_settings():
	var display_settings = {}
	if config.has_section("display"):
		for key in config.get_section_keys("display"):
			display_settings[key] = config.get_value("display", key)
	else:
		print("Display settings not found. Creating defaults.")
		create_default_display_settings()
		display_settings = load_display_settings()
	return display_settings

func save_audio_settings(key: String, value):
	config.set_value("audio", key, value)
	var err = config.save(SETTINGS_FILE_PATH)
	if err != OK:
		printerr("Failed to save audio settings. Error code: ", err)

func load_audio_settings():
	var audio_settings = {}
	if config.has_section("audio"):
		for key in config.get_section_keys("audio"):
			audio_settings[key] = config.get_value("audio", key)
	else:
		print("Audio settings not found. Creating defaults.")
		create_default_audio_settings()
		audio_settings = load_audio_settings()
	return audio_settings
