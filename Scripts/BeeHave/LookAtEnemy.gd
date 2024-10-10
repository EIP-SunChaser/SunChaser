class_name LookAtEnemy extends ActionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	actor.rotate_node = actor.enemy
	return SUCCESS
