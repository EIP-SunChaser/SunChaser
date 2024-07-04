extends Area3D

var target_position: Vector3
var is_moving: bool = false

func action() -> void:
	is_moving = true

func _physics_process(_delta) -> void:
	if not is_moving:
		return
	
	var cars = get_tree().get_nodes_in_group("JoltCar")
	if cars.is_empty():
		is_moving = false
		return
	
	var car = cars.front()
	var current_position = car.global_transform.origin
	
	var call_button = get_parent()	
	target_position = Vector3(-14, 5, 1)
	car.set_global_rotation_degrees(Vector3(0, 90, 0))
	
	if current_position.distance_to(target_position) > 0.1:
		car.global_transform.origin = target_position
	else:
		car.global_transform.origin = target_position
		is_moving = false
