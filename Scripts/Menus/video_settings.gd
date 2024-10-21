extends Control

@onready var resolution_option = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Display/Resolution/ResolutionOption
@onready var fullscreen_option = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Display/Fullscreen/FullscreenOption
@onready var vsync_check = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Display/VSync/VSyncCheck
@onready var framerate_option = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Display/Framerate/FramerateOption
@onready var msaa_option = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Display/MSAA/MSAAOption
@onready var fxaa_check = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Display/FXAA/FXAACheck
@onready var tab_container: TabContainer = $".."

var is_fullscreen: bool = false
var display_settings

func _ready():
	populate_resolution_options()
	populate_window_mode()
	populate_framerate_options()
	populate_msaa_options()
	apply_settings()
	visibility_changed.connect(_on_visibility_changed)
	tab_container.get_tab_bar().grab_focus()

func _on_visibility_changed():
	if visible and get_tree().current_scene.name != "MainMenu":
		tab_container.get_tab_bar().grab_focus()

func apply_settings():
	display_settings = ConfigFileHandler.load_display_settings()

	resolution_option.selected = display_settings.resolution
	fullscreen_option.selected = display_settings.window_mode
	vsync_check.button_pressed = display_settings.vsync
	framerate_option.selected = display_settings.framerate
	msaa_option.selected = display_settings.msaa
	fxaa_check.button_pressed = display_settings.fxaa

	_on_resolution_option_item_selected(display_settings.resolution)
	_on_fullscreen_option_item_selected(display_settings.window_mode)
	_on_v_sync_check_toggled(display_settings.vsync)
	_on_framerate_option_item_selected(display_settings.framerate)
	_on_msaa_option_item_selected(display_settings.msaa)
	_on_fxaa_check_toggled(display_settings.fxaa)

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
		{"mode": DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN, "name": "Exclusive Fullscreen"},
		{"mode": DisplayServer.WINDOW_MODE_FULLSCREEN, "name": "Fullscreen"},
		{"mode": DisplayServer.WINDOW_MODE_MAXIMIZED, "name": "Maximized"},
		{"mode": DisplayServer.WINDOW_MODE_WINDOWED, "name": "Windowed"}
	]

	for i in range(window_modes.size()):
		fullscreen_option.add_item(window_modes[i].name, window_modes[i].mode)
		if window_modes[i].mode == current_mode:
			fullscreen_option.select(i)

func populate_framerate_options():
	var framerates = [30, 60, 120, 144, 240, 0]
	var current_framerate = Engine.max_fps

	for i in range(framerates.size()):
		var text = str(framerates[i]) if framerates[i] > 0 else "Unlimited"
		framerate_option.add_item(text, framerates[i])
		if framerates[i] == current_framerate:
			framerate_option.select(i)

func populate_msaa_options():
	var msaa_modes = [
		{"mode": Viewport.MSAA_DISABLED, "name": "Disabled"},
		{"mode": Viewport.MSAA_2X, "name": "2x"},
		{"mode": Viewport.MSAA_4X, "name": "4x"},
		{"mode": Viewport.MSAA_8X, "name": "8x"}
	]

	for i in range(msaa_modes.size()):
		msaa_option.add_item(msaa_modes[i].name, msaa_modes[i].mode)

func _on_resolution_option_item_selected(index):
	var selected_resolution = resolution_option.get_item_text(index).split("x")
	get_window().size = Vector2(int(selected_resolution[0]), int(selected_resolution[1]))
	ConfigFileHandler.save_display_settings("resolution", index)

func _on_fullscreen_option_item_selected(index):
	var selected_mode = fullscreen_option.get_item_id(index)
	DisplayServer.window_set_mode(selected_mode)
	ConfigFileHandler.save_display_settings("window_mode", index)

func _on_v_sync_check_toggled(button_pressed):
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if button_pressed else DisplayServer.VSYNC_DISABLED)
	ConfigFileHandler.save_display_settings("vsync", button_pressed)

func _on_framerate_option_item_selected(index):
	var selected_framerate = framerate_option.get_item_id(index)
	Engine.max_fps = selected_framerate
	ConfigFileHandler.save_display_settings("framerate", index)

func _on_msaa_option_item_selected(index):
	var selected_msaa = msaa_option.get_item_id(index)
	get_viewport().msaa_3d = selected_msaa
	ConfigFileHandler.save_display_settings("msaa", index)

func _on_fxaa_check_toggled(button_pressed):
	get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA if button_pressed else Viewport.SCREEN_SPACE_AA_DISABLED
	ConfigFileHandler.save_display_settings("fxaa", button_pressed)

func _on_reset_button_pressed():
	display_settings = ConfigFileHandler.DisplaySettings.new()
	resolution_option.selected = display_settings.resolution
	fullscreen_option.selected = display_settings.window_mode
	vsync_check.button_pressed = display_settings.vsync
	msaa_option.selected = display_settings.msaa
	fxaa_check.button_pressed = display_settings.fxaa
	framerate_option.selected = display_settings.framerate

	_on_resolution_option_item_selected(resolution_option.selected)
	_on_fullscreen_option_item_selected(fullscreen_option.selected)
	_on_v_sync_check_toggled(vsync_check.button_pressed)
	_on_framerate_option_item_selected(framerate_option.selected)
	_on_msaa_option_item_selected(msaa_option.selected)
	_on_fxaa_check_toggled(fxaa_check.button_pressed)
