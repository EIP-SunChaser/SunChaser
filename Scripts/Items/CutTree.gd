extends Area3D

func action() -> void:
	var tree = get_parent()
	tree.position.y -= 1
	tree.rotation_degrees.x = 0
