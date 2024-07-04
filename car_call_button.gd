extends Area3D

func action() -> void:
	var car = get_tree().get_nodes_in_group("JoltCar")
	var call_button = get_parent()
	
	car.front().global_transform.origin = Vector3(call_button.position.x - 2, call_button.position.y, call_button.position.z)
	car.front().set_global_rotation_degrees(Vector3(0, 90, 0))

