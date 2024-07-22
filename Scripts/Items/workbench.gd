extends Control

@onready var workbench_menu = $"../WorkbenchMenu"
@onready var animation_player = $"../WorkbenchMenu/AnimationPlayer"
@onready var camera_3d = $"../Camera3D"

@export var enter_speed = 5.0
@export var enter_distance = 10.0
@export var reverse_speed = 10.0
@export var reverse_distance = 15.0
@export var rotation_speed = 0.1

var car
var initial_position: Vector3
var target_rotation: Vector3
var is_entering = false
var is_reversing = false
var original_wheel

func _on_area_3d_body_entered(body):
	if !is_multiplayer_authority(): return
	if body.is_in_group("JoltCar"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		GlobalVariables.isInDialogue = true
		workbench_menu.show()
		animation_player.play("menu_opening")
		car = body
		car.linear_velocity = Vector3.ZERO
		store_original_wheels()
		initialize_enter_movement()

func _physics_process(_delta):
	if car:
		if is_entering:
			update_enter_movement()
		elif is_reversing:
			update_reverse_movement()

func initialize_enter_movement():
	var current_rotation = car.global_transform.basis.get_euler()
	current_rotation.y = 0
	target_rotation = current_rotation

	initial_position = car.global_position
	is_entering = true
	CameraTransition.transition_camera3D(car.camera_3d, camera_3d)
	set_physics_process(true)

func update_enter_movement():
	reset_wheel_rotations()
	car.steering_enabled = false

	var current_rotation = car.global_transform.basis.get_euler()
	current_rotation.y = lerp(current_rotation.y, target_rotation.y, rotation_speed)
	car.global_transform = Transform3D(Basis().rotated(Vector3.UP, current_rotation.y), car.global_position)

	var forward_direction = car.global_transform.basis.z.normalized() * -1
	car.linear_velocity = forward_direction * enter_speed

	if car.global_position.distance_to(initial_position) >= enter_distance:
		car.parking_brake_engaged = true
		car.linear_velocity = Vector3.ZERO
		is_entering = false
		set_physics_process(false)

func update_reverse_movement():
	reset_wheel_rotations()
	car.steering_enabled = false

	var backward_direction = Vector3(0, 0, 1)
	car.linear_velocity = backward_direction * reverse_speed

	if car.global_position.distance_to(initial_position) >= reverse_distance:
		workbench_menu.hide()
		car.linear_velocity = Vector3.ZERO
		car.steering_enabled = true
		is_reversing = false
		CameraTransition.transition_camera3D(camera_3d, car.camera_3d)
		set_physics_process(false)

func reset_wheel_rotations():
	car.front_left_wheel.rotation.y = 0
	car.front_right_wheel.rotation.y = 0

func start_reverse_movement():
	if car:
		car.parking_brake_engaged = false
		initial_position = car.global_position
		is_reversing = true
		set_physics_process(true)

func _on_save_button_pressed():
	if !is_entering:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		GlobalVariables.isInDialogue = false
		animation_player.play_backwards("menu_opening")
		start_reverse_movement()

func _on_cancel_button_pressed():
	if !is_entering:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		GlobalVariables.isInDialogue = false
		toggle_wheels(original_wheel)
		animation_player.play_backwards("menu_opening")
		start_reverse_movement()

func toggle_wheels(wheel_index: int):
	if car:
		for pair in car.wheel_pairs:
			pair[0].visible = (wheel_index == 0)
			pair[1].visible = (wheel_index == 1)
			pair[2].visible = (wheel_index == 2)

func store_original_wheels():
	if car:
		var index := 0
		for pair in car.wheel_pairs:
			if pair[index].visible == true:
				original_wheel = index
				return
			index += 1

func _on_button_pressed():
		toggle_wheels(0)

func _on_button_2_pressed():
		toggle_wheels(1)

func _on_button_3_pressed():
		toggle_wheels(2)
