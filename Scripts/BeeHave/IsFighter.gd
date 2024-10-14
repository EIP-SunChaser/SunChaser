class_name IsFigter extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if not actor.isFighter:
		return SUCCESS
	return FAILURE
