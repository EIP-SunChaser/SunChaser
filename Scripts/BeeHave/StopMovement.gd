class_name StopMovement extends ActionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	actor.stop_movement()
	return SUCCESS
