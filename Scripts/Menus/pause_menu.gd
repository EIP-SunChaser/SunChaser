extends Control

var player: CharacterBody3D

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	player = get_parent()

func _on_resume_button_button_down():
	player.pauseMenu()


func _on_options_button_down():
	print("Options")


func _on_back_to_main_menu_button_down():
	player.pauseMenu()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")


func _on_exit_to_desktop_button_down():
	get_tree().quit()
