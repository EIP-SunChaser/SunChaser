extends Area3D

func action() -> void:
	var tree = get_parent()
	tree.position.y -= 1
	tree.rotation_degrees.x = 0
	GlobalVariables.grow_tree += 1
	if GlobalVariables.grow_tree >= 6:
		if GlobalVariables.quest_one == GlobalVariables.check_quest.GROW_TREE_TWO:
			GlobalVariables.quest_one = GlobalVariables.check_quest.END_ONE
	else:
		if GlobalVariables.quest_one == GlobalVariables.check_quest.GROW_TREE_TWO:
			GlobalVariables.quest_one = GlobalVariables.check_quest.GROW_TREE_ONE
