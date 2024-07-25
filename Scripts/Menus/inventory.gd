extends Control

var player: RigidBody3D

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	player = get_parent()
