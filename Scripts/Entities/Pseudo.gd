extends Label3D

func _ready():
	var player_number = 0
	for player_id in PlayerManager.Players:
		var player = PlayerManager.Players[player_id]
		if player.id == multiplayer.get_unique_id():
			text = player.name if player.name != "" else "Player" + str(player_number + 1)
			return
		player_number += 1
