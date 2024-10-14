class_name FleeFromTarget extends ActionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	actor.flee_from_target(actor.enemy.global_position)
	return SUCCESS
