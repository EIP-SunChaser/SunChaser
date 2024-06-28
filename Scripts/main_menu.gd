extends Control

@onready var ip_address = $VBoxContainer2/Adress
@onready var pseudo = $VBoxContainer2/Pseudo
@onready var solo_button = $VBoxContainer/Solo

const DEFAULT_PORT = "127.0.0.1"
const PORT = 9999
var peer

func _ready():
	solo_button.grab_focus()
	ip_address.placeholder_text = DEFAULT_PORT
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

func peer_connected(id):
	print("Peer connected " + str(id))
	if multiplayer.is_server():
		await get_tree().create_timer(1.0).timeout

func peer_disconnected(id):
	print("Peer disconnected " + str(id))
	if GameManager.Players.has(id):
		GameManager.Players.erase(id)
		var character_bodies = get_tree().get_nodes_in_group("players")
		for body in character_bodies:
			if body is CharacterBody3D and body.to_string().get_slice(":", 0) == str(id):
				body.queue_free()
		return null

func connected_to_server():
	print("Connected to server!")
	send_player_information.rpc_id(1, pseudo.text, multiplayer.get_unique_id())

func connection_failed():
	print("Connection failed!")

func _process(delta):
	pass

@rpc("any_peer")
func send_player_information(name, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name": name,
			"id": id
		}
	if multiplayer.is_server():
		for i in GameManager.Players:
			send_player_information.rpc(GameManager.Players[i].name, i)

@rpc("any_peer", "call_local")
func start_game():
	print("Starting game...")
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
	send_player_information(pseudo.text, multiplayer.get_unique_id())
	print("Waiting for players!")

func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	if ip_address.text != "":
		peer.create_client(ip_address.text, PORT)
	else:
		peer.create_client(DEFAULT_PORT, PORT)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

func disconnect_multiplayer():
	print("Disconnected from server")

func _on_exit_button_down():
	disconnect_multiplayer()
	get_tree().quit()

func _on_solo_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT)
	if error != OK:
		print("Failed to create local server! ", error)
		return
	multiplayer.set_multiplayer_peer(peer)
	send_player_information(pseudo.text, multiplayer.get_unique_id())
	await get_tree().create_timer(0.001).timeout
	start_game()
