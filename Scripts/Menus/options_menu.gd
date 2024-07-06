extends Control

@onready var exit_button = $MarginContainer/VBoxContainer/ExitButton

signal exit_options_menu

func _on_exit_button_button_down():
	exit_options_menu.emit()
