extends Control

var player: CharacterBody3D

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	player = get_parent()
	print("player")
