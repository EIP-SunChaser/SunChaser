extends Control

var player: CharacterBody3D
@onready var options_button = $VBoxContainer/OptionsButton
@onready var options_menu = $options_menu
@onready var v_box_container = $VBoxContainer
@onready var resume_button = $VBoxContainer/ResumeButton

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	player = get_parent()
	options_menu.exit_options_menu.connect(on_exit_options_menu)
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if visible:
		resume_button.grab_focus()

func _on_resume_button_button_down():
	player.pauseMenu()

func _on_options_button_down():
	v_box_container.hide()
	options_menu.show()

func on_exit_options_menu():
	v_box_container.show()
	options_menu.hide()
	resume_button.grab_focus()

@rpc("any_peer", "call_local")
func reset_all():
	var players = get_tree().get_nodes_in_group("Player")
	var cars = get_tree().get_nodes_in_group("Car")
	for i in players:
		i.queue_free()
	for i in cars:
		i.queue_free()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
	await get_tree().create_timer(0.1).timeout 
	if multiplayer.has_multiplayer_peer():
		multiplayer.multiplayer_peer.close()

@rpc("any_peer", "call_local")
func reset_player(id):
	var players = get_tree().get_nodes_in_group("Player")
	for i in players:
		if i.name == str(id):
			print("Player " + str(id) + " deleted!")
			i.queue_free()

func _on_back_to_main_menu_button_down():
	player.pauseMenu()
	if multiplayer.is_server():
		reset_all.rpc()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		reset_player.rpc(multiplayer.get_unique_id())
		get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")

func _on_exit_to_desktop_button_down():
	if multiplayer.is_server():
		reset_all.rpc()
	get_tree().quit()
