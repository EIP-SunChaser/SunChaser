extends Control

var player: CharacterBody3D
@onready var options_button = $VBoxContainer/OptionsButton
@onready var options_menu = $options_menu
@onready var v_box_container = $VBoxContainer
@onready var resume_button = $VBoxContainer/ResumeButton
@onready var main_menu = $"/root/MainMenu"

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
func reset_game(id: int) -> void:
	var id_str := str(id)
	
	for car in get_tree().get_nodes_in_group("Car"):
		if car.name.ends_with(id_str):
			print(car)
			car.queue_free()
			break
	
	var player_to_remove: Node = null
	for player in get_tree().get_nodes_in_group("Player"):
		if player.name == id_str:
			player_to_remove = player
			break
	
	if player_to_remove:
		if id != 1:
			multiplayer.multiplayer_peer.disconnect_peer(id)
		main_menu.delete_player(id)
	
	if multiplayer.get_unique_id() == id:
		main_menu.queue_free()
		get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")

func _on_back_to_main_menu_button_down():
	player.pauseMenu()
	reset_game.rpc(multiplayer.get_unique_id())

func _on_exit_to_desktop_button_down():
	get_tree().quit()
