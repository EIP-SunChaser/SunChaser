extends Control

@onready var master_slider = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Volume/MasterVolume/MasterSlider
@onready var music_slider = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Volume/MusicVolume/MusicSlider
@onready var sound_effects_slider = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Volume/SoundEffectsVolume/SoundEffectsSlider
@onready var master_percentage = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Volume/MasterVolume/MasterPercentage
@onready var music_percentage = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Volume/MusicVolume/MusicPercentage
@onready var sound_effects_percentage = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Volume/SoundEffectsVolume/SoundEffectsPercentage

@onready var tab_container: TabContainer = $".."

var audio_settings

func _ready():
	apply_settings()
	visibility_changed.connect(_on_visibility_changed)
	tab_container.get_tab_bar().grab_focus()

func _on_visibility_changed():
	if visible and get_tree().current_scene.name != "MainMenu":
		pass
		tab_container.get_tab_bar().grab_focus()

func apply_settings():
	audio_settings = ConfigFileHandler.load_audio_settings()

	master_slider.value = audio_settings.master_volume
	music_slider.value = audio_settings.music_volume
	sound_effects_slider.value = audio_settings.sfx_volume

func _on_master_slider_value_changed(value):
	master_percentage.text = str(master_slider.value * 100) + "%"
	AudioServer.set_bus_volume_db(0, linear_to_db(master_slider.value))
	ConfigFileHandler.save_audio_settings("master_volume", value)

func _on_music_slider_value_changed(value):
	music_percentage.text = str(music_slider.value * 100) + "%"
	AudioServer.set_bus_volume_db(1, linear_to_db(music_slider.value))
	ConfigFileHandler.save_audio_settings("music_volume", value)

func _on_sound_effects_slider_value_changed(value):
	sound_effects_percentage.text = str(sound_effects_slider.value * 100) + "%"
	AudioServer.set_bus_volume_db(2, linear_to_db(sound_effects_slider.value))
	ConfigFileHandler.save_audio_settings("sfx_volume", value)

func _on_reset_button_pressed():
	audio_settings = ConfigFileHandler.AudioSettings.new()
	master_slider.value = audio_settings.master_volume
	music_slider.value = audio_settings.music_volume
	sound_effects_slider.value = audio_settings.sfx_volume
