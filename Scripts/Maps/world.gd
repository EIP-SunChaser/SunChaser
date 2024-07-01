extends Node3D

@export var player_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	var index = 0
	for i in PlayerManager.Players:
		var current_player = player_scene.instantiate()
		current_player.name = str(PlayerManager.Players[i].id)
		current_player.add_to_group("players")		
		add_child(current_player)
		for spawn in get_tree().get_nodes_in_group("SpawnPoints"):
			if spawn.name == str(index):
				current_player.global_position = spawn.global_position
		index += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
