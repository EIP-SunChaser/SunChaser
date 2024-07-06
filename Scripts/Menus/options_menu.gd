extends Control

@onready var exit_button = $MarginContainer/VBoxContainer/ExitButton

signal exit_options_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_exit_button_button_down():
	exit_options_menu.emit()
