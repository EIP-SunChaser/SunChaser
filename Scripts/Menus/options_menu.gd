extends Control

@onready var exit_button = $MarginContainer/VBoxContainer/VBoxContainer/ExitButton
@onready var background = $Background
@onready var tab_container: TabContainer = $MarginContainer/VBoxContainer/settings_tab_container/TabContainer

signal exit_options_menu

@onready var controls_settings: Control = $MarginContainer/VBoxContainer/settings_tab_container/TabContainer/Controls
@onready var video_settings: Control = $MarginContainer/VBoxContainer/settings_tab_container/TabContainer/Video
@onready var audio_settings: Control = $MarginContainer/VBoxContainer/settings_tab_container/TabContainer/Audio

var is_button_focused: bool = false

func _ready():
	if get_parent().name == "root":
		background.show()


func _on_exit_button_button_down():
	if get_parent().name == "root":
		background.hide()
		get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
	else:
		exit_options_menu.emit()


func _on_reset_button_button_down() -> void:
	match tab_container.current_tab:
		0:
			if video_settings.has_method("_on_reset_button_pressed"):
				video_settings._on_reset_button_pressed()
		1:
			if audio_settings.has_method("_on_reset_button_pressed"):
				audio_settings._on_reset_button_pressed()
		2:
			if controls_settings.has_method("create_action_list"):
				controls_settings.create_action_list()


func _input(_event: InputEvent) -> void:
	if (Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")) and is_button_focused:
		tab_container.get_tab_bar().grab_focus()
	if Input.is_action_pressed("cancel"):
		if get_parent().name == "root":
			background.hide()
			get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
		else:
			exit_options_menu.emit()

func _on_button_focus_entered() -> void:
	is_button_focused = true

func _on_button_focus_exited() -> void:
	is_button_focused = false
