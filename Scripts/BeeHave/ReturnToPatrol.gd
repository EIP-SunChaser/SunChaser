class_name ReturnToPatrol extends ActionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	actor.return_to_patrol()
	return FAILURE
