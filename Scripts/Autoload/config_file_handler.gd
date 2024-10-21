extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"

class DisplaySettings:
	var resolution: int = 0
	var window_mode: int = 0
	var vsync: bool = true
	var fxaa: int = Viewport.SCREEN_SPACE_AA_DISABLED
	var msaa: int = Viewport.MSAA_DISABLED
	var framerate: int = 5

class AudioSettings:
	var master_volume: float = 0.50
	var music_volume: float = 0.50
	var sfx_volume: float = 0.50

var display_settings = DisplaySettings.new()
var audio_settings = AudioSettings.new()

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
	config.set_value("display", "resolution", display_settings.resolution)
	config.set_value("display", "window_mode", display_settings.window_mode)
	config.set_value("display", "vsync", display_settings.vsync)
	config.set_value("display", "fxaa", display_settings.fxaa)
	config.set_value("display", "msaa", display_settings.msaa)
	config.set_value("display", "framerate", display_settings.framerate)

func create_default_audio_settings():
	config.set_value("audio", "master_volume", audio_settings.master_volume)
	config.set_value("audio", "music_volume", audio_settings.music_volume)
	config.set_value("audio", "sfx_volume", audio_settings.sfx_volume)

func save_display_settings(key: String, value):
	config.set_value("display", key, value)
	var err = config.save(SETTINGS_FILE_PATH)
	if err != OK:
		printerr("Failed to save display settings. Error code: ", err)

func load_display_settings():
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
	if config.has_section("audio"):
		for key in config.get_section_keys("audio"):
			audio_settings[key] = config.get_value("audio", key)
	else:
		print("Audio settings not found. Creating defaults.")
		create_default_audio_settings()
		audio_settings = load_audio_settings()
	return audio_settings
