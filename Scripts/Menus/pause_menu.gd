extends Control

var player: CharacterBody3D
@onready var input_settings = $VBoxContainer/input_settings
@onready var options_button = $VBoxContainer/OptionsButton
@onready var options_menu = $options_menu
@onready var v_box_container = $VBoxContainer

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	player = get_parent()
	options_menu.exit_options_menu.connect(on_exit_options_menu)

func _on_resume_button_button_down():
	player.pauseMenu()


func _on_options_button_down():
	v_box_container.hide()
	options_menu.show()

func on_exit_options_menu():
	v_box_container.show()
	options_menu.hide()

func _on_back_to_main_menu_button_down():
	player.pauseMenu()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")


func _on_exit_to_desktop_button_down():
	get_tree().quit()
