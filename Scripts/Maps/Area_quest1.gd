extends Area3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GlobalVariables.quest_one == GlobalVariables.check_quest.GO_CAMP_TWO:
		GlobalVariables.quest_one = GlobalVariables.check_quest.KILL_RED_ONE
