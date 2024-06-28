extends Node3D

@export var player_scene: PackedScene
@export var car_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	var index = 0
	for i in GameManager.Players:
		var current_player = player_scene.instantiate()
		var current_player_car = car_scene.instantiate()
		current_player.name = str(GameManager.Players[i].id)
		current_player_car.name = str(GameManager.Players[i].id)
		current_player.add_to_group("players")		
		add_child(current_player)
		add_child(current_player_car)
		for spawn in get_tree().get_nodes_in_group("SpawnPoints"):
			if spawn.name == str(index):
				current_player.global_position = spawn.global_position
				current_player_car.global_position = spawn.global_position
		index += 1
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
