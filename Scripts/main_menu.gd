extends Control

@onready var ip_adress = $VBoxContainer2/Adress
@onready var pseudo = $VBoxContainer2/Pseudo
@onready var start_button = $VBoxContainer/Start

const DEFAULT_PORT = "127.0.0.1"
const PORT = 9999
var peer

# Called when the node enters the scene tree for the first time.
func _ready():
	ip_adress.placeholder_text = DEFAULT_PORT
	start_button.grab_focus()
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

func peer_connected(id):
	print("Peer connected " + str(id))

func peer_disconnected(id):
	print("Peer disconnected " + str(id))

func connected_to_server():
	print("Connected to server!")
	send_player_information.rpc_id(1, pseudo.text, multiplayer.get_unique_id())

func connection_failed():
	print("Connection failed!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@rpc("any_peer")
func send_player_information(name, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] ={
			"name": name,
			"id": id
		}
	if multiplayer.is_server():
		for i in GameManager.Players:
			send_player_information.rpc(GameManager.Players[i].name, i)

@rpc("any_peer", "call_local")
func start_game():
	var scene = load("res://Scenes/world.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _on_start_button_down():
	start_game.rpc()

func _on_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT)
	if error != OK:
		print("Failed to create server! ", error)
		return
	var addresses = []
	for ip in IP.get_local_addresses():
		if ip.begins_with("10.") or ip.begins_with("172.16.") or ip.begins_with("192.168."):
			addresses.push_back(ip)
	DisplayServer.clipboard_set(addresses[-1])
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players!")
	send_player_information(pseudo.text, multiplayer.get_unique_id())


func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	if ip_adress.text != "":
		peer.create_client(ip_adress.text, PORT)
	else:
		peer.create_client(DEFAULT_PORT, PORT)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)


func _on_exit_button_down():
	get_tree().quit()
