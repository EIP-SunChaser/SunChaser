class_name IsAtPatrol extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.is_at_patrol():
		return SUCCESS
	return FAILURE
