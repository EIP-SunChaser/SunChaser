extends Control

@onready var master_slider = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Volume/MasterVolume/MasterSlider
@onready var music_slider = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Volume/MusicVolume/MusicSlider
@onready var sound_effects_slider = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Volume/SoundEffectsVolume/SoundEffectsSlider

@onready var master_percentage = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Volume/MasterVolume/MasterPercentage
@onready var music_percentage = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Volume/MusicVolume/MusicPercentage
@onready var sound_effects_percentage = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Volume/SoundEffectsVolume/SoundEffectsPercentage

func _ready():
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(1))
	sound_effects_slider.value = db_to_linear(AudioServer.get_bus_volume_db(2))

func _on_master_slider_value_changed(value):
	master_percentage.text = str(master_slider.value * 100) + "%"
	AudioServer.set_bus_volume_db(0, linear_to_db(master_slider.value))

func _on_music_slider_value_changed(value):
	music_percentage.text = str(music_slider.value * 100) + "%"
	AudioServer.set_bus_volume_db(1, linear_to_db(music_slider.value))

func _on_sound_effects_slider_value_changed(value):
	sound_effects_percentage.text = str(sound_effects_slider.value * 100) + "%"
	AudioServer.set_bus_volume_db(2, linear_to_db(sound_effects_slider.value))

func _on_reset_button_pressed():
	master_slider.value = 1
	music_slider.value = 1
	sound_effects_slider.value = 1
