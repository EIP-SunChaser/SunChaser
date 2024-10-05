class_name SelectNewLocation extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	actor.choose_random_target()
	return SUCCESS
