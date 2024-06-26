extends Label3D

@onready var multiplayer_synchronizer = $"../../MultiplayerSynchronizer"

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer_synchronizer.set_multiplayer_authority(str(name).to_int())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if multiplayer_synchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		for i in GameManager.Players:
				if GameManager.Players[i].id == multiplayer.get_unique_id():
					text = GameManager.Players[i].name
