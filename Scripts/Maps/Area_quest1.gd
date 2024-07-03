extends Area3D

var local_player
var quest_zone = false
var players_in_zone = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if  quest_zone == true:
		if GlobalVariables.quest_one == GlobalVariables.check_quest.GO_CAMP_TWO:
			GlobalVariables.quest_one = GlobalVariables.check_quest.KILL_RED_ONE

func _on_body_entered(body):
	players_in_zone.append(body)
	if body.is_in_group("Players") || body.is_in_group("JoltCar"):
		quest_zone = true


func _on_body_exited(body):
	players_in_zone.erase(body)
	quest_zone = players_in_zone.size() > 0
	if body.is_in_group("Players") || body.is_in_group("JoltCar"):
		quest_zone = false
