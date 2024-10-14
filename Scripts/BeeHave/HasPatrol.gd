class_name HasPatrol extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.has_patrol():
		return SUCCESS
	return FAILURE
