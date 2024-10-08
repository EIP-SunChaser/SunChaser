extends Control

@onready var exit_button = $MarginContainer/VBoxContainer/ExitButton
@onready var background = $Background

signal exit_options_menu
signal exit_button_focused


func _ready():
	if get_parent().name == "root":
		background.show()


func _on_exit_button_button_down():
	if get_parent().name == "root":
		background.hide()
		get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
	else:
		exit_options_menu.emit()


func _on_exit_button_focus_entered() -> void:
	exit_button_focused.emit()
