class_name IsArrived extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.is_at_destination():
		return SUCCESS
	else:
		return RUNNING
