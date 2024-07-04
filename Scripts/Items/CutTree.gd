extends Area3D

func action() -> void:
	var tree = get_parent()
	if tree.position.y != 17.5:
		tree.position.y = 17.5
		tree.rotation_degrees.x = 0
		GlobalVariables.grow_tree += 1
		if GlobalVariables.grow_tree >= 6:
			if GlobalVariables.quest_one == GlobalVariables.check_quest.GROW_TREE_TWO:
				GlobalVariables.quest_one = GlobalVariables.check_quest.END_ONE
		else:
			if GlobalVariables.quest_one == GlobalVariables.check_quest.GROW_TREE_TWO:
				GlobalVariables.quest_one = GlobalVariables.check_quest.GROW_TREE_ONE
	else:
		pass
