class_name IncrementPatrol extends ActionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	actor.increment_patrol()
	return SUCCESS
