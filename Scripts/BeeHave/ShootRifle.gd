class_name ShootRifle extends ActionLeaf

func tick(actor:Node, _blackboard:Blackboard) -> int:
	actor.rifle.spawnNewBullet()
	actor.rifle.playShootingAnimation()
	return SUCCESS
