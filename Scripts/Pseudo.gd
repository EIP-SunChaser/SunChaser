extends Label3D

@onready var multiplayer_synchronizer = $"../MultiplayerSynchronizer"

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

# Called when the node enters the scene tree for the first time.
func _ready():
	if !is_multiplayer_authority(): return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if multiplayer_synchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		var player_number = 1
		for i in PlayerManager.Players:
			if PlayerManager.Players[i].id == multiplayer.get_unique_id():
				if PlayerManager.Players[i].name != "":
					text = PlayerManager.Players[i].name
				else:
					text = "Player" + str(player_number)
				break
			player_number += 1
