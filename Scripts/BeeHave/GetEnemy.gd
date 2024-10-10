class_name GetEnemy extends ConditionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	var _e = actor.senses.get_enemy()
	if _e == null:
		actor.rotate_node = null
		actor.enemy = null
		return FAILURE
	else:
		actor.enemy = _e
		return SUCCESS
