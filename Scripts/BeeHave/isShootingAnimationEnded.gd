class_name isShootingAnimationEnded extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	if actor.rifle.isAnimationEnded():
		return SUCCESS
	return RUNNING
