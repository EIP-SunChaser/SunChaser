extends Control

@export var player_scene: PackedScene
@export var car_scene: PackedScene

@onready var pseudo = $BoxContainer/VBoxContainer2/Pseudo
@onready var ip_address = $BoxContainer/VBoxContainer2/IP_Address
@onready var host = $BoxContainer/VBoxContainer/Host

var current_spawn_index = 0

const PORT = 9999
const DEFAULT_IP = "127.0.0.1"
var peer = ENetMultiplayerPeer.new()

func _ready():
	ip_address.placeholder_text = "Enter the host IP! Default is " + DEFAULT_IP
	multiplayer.connected_to_server.connect(connected_to_server)
	host.grab_focus()
	#Engine.max_fps = 30
	
	# Spawn already connected players
	

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
	upnp_setup()

func _on_join_button_down():
	if ip_address.text != "":
		peer.create_client(ip_address.text, PORT)
	else:
		peer.create_client(DEFAULT_IP, PORT)
	multiplayer.multiplayer_peer = peer
	self.hide()

func _on_exit_button_down():
	get_tree().quit()

func add_player(id: int):
	if multiplayer.is_server():
		var spawn_position = select_spawn_point()
		spawn_player(id, spawn_position)
		
		var car_spawn_position = select_car_spawn_point(spawn_position)
		spawn_car(car_spawn_position)

func spawn_car(spawn_position: Vector3):
	var car = car_scene.instantiate()
	car.name = "JoltCar"
	car.add_to_group("Car")
	$"../Node3D".add_child(car, true)
	car.global_position = spawn_position
	print("JoltCar spawned!")

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
	#add_child(player)
	$"../Node3D".add_child(player, true)
	# Use call_deferred to set the position after the node is added to the scene
	player.call_deferred("set_global_position", spawn_position)
	print("Player " + str(id) + " added!")

func select_spawn_point() -> Vector3:
	var spawn_points = get_tree().get_nodes_in_group("SpawnPoints")
	if spawn_points.size() > 0:
		var spawn_point = spawn_points[current_spawn_index]
		current_spawn_index = (current_spawn_index + 1) % spawn_points.size()
		return spawn_point.global_position
	else:
		print("Warning: No spawn points found!")
		return Vector3.ZERO

func select_car_spawn_point(base_spawn_position: Vector3) -> Vector3:
	# Adjust the car spawn position relative to the base player spawn position
	return base_spawn_position + Vector3(0, 10, 10)

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


