extends CharacterBody3D

var health = 100

func _on_body_part_hit(dam):
	health -= dam
	if health <= 0:
		if is_in_group("Bandits"):
			GlobalVariables.entity_kill += 1
			if GlobalVariables.entity_kill >= 3:
				if GlobalVariables.quest_one == GlobalVariables.check_quest.KILL_RED_TWO:
					GlobalVariables.quest_one = GlobalVariables.check_quest.TALK_FORESTIERS_ONE
			else:
				if GlobalVariables.quest_one == GlobalVariables.check_quest.KILL_RED_TWO:
					GlobalVariables.quest_one = GlobalVariables.check_quest.KILL_RED_ONE
		queue_free()
