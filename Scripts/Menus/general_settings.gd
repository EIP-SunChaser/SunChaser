extends Control

@onready var master_slider = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Volume/MasterVolume/MasterSlider
@onready var music_slider = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Volume/MusicVolume/MusicSlider
@onready var sound_effects_slider = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Volume/SoundEffectsVolume/SoundEffectsSlider
@onready var master_percentage = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Volume/MasterVolume/MasterPercentage
@onready var music_percentage = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Volume/MusicVolume/MusicPercentage
@onready var sound_effects_percentage = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Volume/SoundEffectsVolume/SoundEffectsPercentage

@onready var resolution_option = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Display/Resolution/ResolutionOption
@onready var fullscreen_option = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Display/Fullscreen/FullscreenOption
@onready var vsync_check = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Display/VSync/VSyncCheck
@onready var framerate_option = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Display/Framerate/FramerateOption

var is_fullscreen: bool = false

func _ready():
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(1))
	sound_effects_slider.value = db_to_linear(AudioServer.get_bus_volume_db(2))
	
	populate_resolution_options()
	populate_window_mode()
	populate_framerate_options()
	resolution_option.selected = 0
	fullscreen_option.selected = DisplayServer.window_get_mode()
	vsync_check.button_pressed = DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED
	framerate_option.selected = 5

func populate_resolution_options():
	var current_resolution = get_window().size
	var resolutions = [current_resolution, Vector2(1280, 720), Vector2(1920, 1080), Vector2(2560, 1440), Vector2(3840, 2160)]
	
	for i in range(resolutions.size()):
		resolution_option.add_item(str(resolutions[i].x) + "x" + str(resolutions[i].y), i)
		if Vector2i(resolutions[i]) == current_resolution:
			resolution_option.select(i)

func populate_window_mode():
	var current_mode = DisplayServer.window_get_mode()
	var window_modes = [
		{"mode": DisplayServer.WINDOW_MODE_FULLSCREEN, "name": "Fullscreen"},
		{"mode": DisplayServer.WINDOW_MODE_MAXIMIZED, "name": "Maximized"},
		{"mode": DisplayServer.WINDOW_MODE_WINDOWED, "name": "Windowed"}
	]
	
	for i in range(window_modes.size()):
		fullscreen_option.add_item(window_modes[i].name, window_modes[i].mode)
		if window_modes[i].mode == current_mode:
			fullscreen_option.select(i)

func populate_framerate_options():
	var framerates = [30, 60, 120, 144, 240, 0]  # 0 means unlimited
	var current_framerate = Engine.max_fps
	
	for i in range(framerates.size()):
		var text = str(framerates[i]) if framerates[i] > 0 else "Unlimited"
		framerate_option.add_item(text, framerates[i])
		if framerates[i] == current_framerate:
			framerate_option.select(i)

func _on_master_slider_value_changed(value):
	master_percentage.text = str(master_slider.value * 100) + "%"
	AudioServer.set_bus_volume_db(0, linear_to_db(master_slider.value))

func _on_music_slider_value_changed(value):
	music_percentage.text = str(music_slider.value * 100) + "%"
	AudioServer.set_bus_volume_db(1, linear_to_db(music_slider.value))

func _on_sound_effects_slider_value_changed(value):
	sound_effects_percentage.text = str(sound_effects_slider.value * 100) + "%"
	AudioServer.set_bus_volume_db(2, linear_to_db(sound_effects_slider.value))

func _on_resolution_option_item_selected(index):
	var selected_resolution = resolution_option.get_item_text(index).split("x")
	get_window().size = Vector2(int(selected_resolution[0]), int(selected_resolution[1]))

func _on_fullscreen_option_item_selected(index):
	var selected_mode = fullscreen_option.get_item_id(index)
	DisplayServer.window_set_mode(selected_mode)

func _on_v_sync_check_toggled(button_pressed):
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if button_pressed else DisplayServer.VSYNC_DISABLED)

func _on_framerate_option_item_selected(index):
	var selected_framerate = framerate_option.get_item_id(index)
	Engine.max_fps = selected_framerate

func _on_reset_button_pressed():
	master_slider.value = 1
	music_slider.value = 1
	sound_effects_slider.value = 1
	
	resolution_option.select(0)
	fullscreen_option.select(0)
	DisplayServer.window_set_mode(fullscreen_option.get_item_id(0))
	vsync_check.button_pressed = false
	framerate_option.select(5)
	Engine.max_fps = framerate_option.get_item_id(5)
