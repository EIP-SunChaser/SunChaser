extends Control

@export var player_scene: PackedScene
@export var car_scene: PackedScene

@onready var pseudo = $BoxContainer/VBoxContainer2/Pseudo
@onready var ip_address = $BoxContainer/VBoxContainer2/IP_Address
@onready var host = $BoxContainer/VBoxContainer/Host
@onready var upnp_checkbox = $BoxContainer/VBoxContainer/Host/upnp
@export var world_scene = preload("res://Scenes/Maps/world.tscn")
var current_spawn_index = 0

const PORT = 9999
const DEFAULT_IP = "127.0.0.1"
var peer = ENetMultiplayerPeer.new()

func _ready():
	ip_address.placeholder_text = "Enter the host IP! Default is " + DEFAULT_IP
	multiplayer.connected_to_server.connect(connected_to_server)
	host.grab_focus()
	upnp_checkbox.button_pressed = false

func _process(_delta):
	pass

func connected_to_server():
	send_player_information.rpc_id(1, pseudo.text, multiplayer.get_unique_id())

func _on_host_button_down():
	self.hide()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(delete_player)
	send_player_information(pseudo.text, multiplayer.get_unique_id())
	add_player(multiplayer.get_unique_id())
	if upnp_checkbox.button_pressed:
		upnp_setup()
	var scene = world_scene.instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene

func _on_join_button_down():
	if ip_address.text != "":
		peer.create_client(ip_address.text, PORT)
	else:
		peer.create_client(DEFAULT_IP, PORT)
	multiplayer.multiplayer_peer = peer
	self.hide()
	var scene = world_scene.instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene

func _on_options_button_down():
	get_tree().change_scene_to_file("res://Scenes/Menus/options_menu.tscn")

func _on_exit_button_down():
	get_tree().quit()

func add_player(id: int):
	await get_tree().create_timer(0.05).timeout
	if multiplayer.is_server():
		var spawn_position = select_spawn_point()
		spawn_player(id, spawn_position)

		var car_spawn_position = spawn_position + Vector3(0, 10, 10)
		spawn_car(car_spawn_position)

func spawn_car(spawn_position: Vector3):
	var car = car_scene.instantiate()
	car.name = "JoltCar"
	car.add_to_group("Car")
	add_child(car, true)
	car.global_position = spawn_position

func delete_player(id: int):
	var players = get_tree().get_nodes_in_group("Player")
	for i in players:
		if i.name == str(id):
			print("Player " + str(id) + " deleted!")
			i.queue_free()

func spawn_player(id: int, spawn_position: Vector3):
	var player = player_scene.instantiate()
	player.name = str(id)
	player.add_to_group("Player")
	add_child(player)
	set_player_position.rpc(id, spawn_position)
	print("Player " + str(id) + " added!")

@rpc("any_peer", "call_local")
func set_player_position(id: int, choosed_position: Vector3):
	var player = get_node_or_null(str(id))
	if player:
		player.global_position = choosed_position

func select_spawn_point() -> Vector3:
	var spawn_points = get_tree().get_nodes_in_group("SpawnPoints")
	if spawn_points.size() > 0:
		var spawn_point = spawn_points[current_spawn_index]
		current_spawn_index = (current_spawn_index + 1) % spawn_points.size()
		return spawn_point.global_position
	else:
		print("Warning: No spawn points found!")
		return Vector3.ZERO

@rpc("any_peer")
func send_player_information(PlayerName, id):
	if not PlayerManager.Players.has(id):
		PlayerManager.Players[id] = {
			"name": PlayerName,
			"id": id
		}
	if multiplayer.is_server():
		for i in PlayerManager.Players:
			send_player_information.rpc(PlayerManager.Players[i].name, i)

func upnp_setup():
	var upnp = UPNP.new()
	var discover_result = upnp.discover()
	if discover_result != UPNP.UPNP_RESULT_SUCCESS:
		print("UPNP Discover Failed! Error: ", discover_result)
		return false

	if not upnp.get_gateway() or not upnp.get_gateway().is_valid_gateway():
		print("UPNP Invalid Gateway!")
		return false

	var map_result = upnp.add_port_mapping(PORT)
	if map_result != UPNP.UPNP_RESULT_SUCCESS:
		print("UPNP Port Mapping Failed! Error: ", map_result)
		return false

	var external_address = upnp.query_external_address()
	if external_address == "":
		print("Failed to get external address")
		return false

	print("UPNP Setup Successful! Join Address: ", external_address)
	return true
