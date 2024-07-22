extends Control

@onready var workbench_menu = $"../WorkbenchMenu"
@onready var animation_player = $"../WorkbenchMenu/AnimationPlayer"
@onready var camera_3d = $"../Camera3D"
@onready var specific_parts = $LeftMenu/VBoxContainer/ScrollContainer/VBoxContainer/SpecificParts
@onready var wheels_button = $LeftMenu/VBoxContainer/ScrollContainer/VBoxContainer/CarParts/Wheels

@export var enter_speed = 5.0
@export var enter_distance = 10.0
@export var reverse_speed = 10.0
@export var reverse_distance = 15.0
@export var rotation_speed = 0.1

enum CarState { IDLE, ENTERING, REVERSING }

var car
var initial_position: Vector3
var target_rotation: Vector3
var car_state: CarState = CarState.IDLE
var original_wheel
var original_spring
var current_selection = "wheels"

func _on_area_3d_body_entered(body):
	if !is_multiplayer_authority(): return
	if body.is_in_group("JoltCar") and body.active:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		GlobalVariables.isInDialogue = true
		workbench_menu.show()
		wheels_button.grab_focus()
		animation_player.play("menu_opening")
		car = body
		car.linear_velocity = Vector3.ZERO
		store_original_parts()
		initialize_enter_movement()

func _physics_process(_delta):
	if car:
		match car_state:
			CarState.ENTERING:
				update_enter_movement()
			CarState.REVERSING:
				update_reverse_movement()

func initialize_enter_movement():
	var current_rotation = car.global_transform.basis.get_euler()
	current_rotation.y = 0
	target_rotation = current_rotation

	initial_position = car.global_position
	car_state = CarState.ENTERING
	await CameraTransition.transition_camera3D(car.camera_3d, camera_3d)
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
		car.linear_velocity = Vector3.ZERO
		car_state = CarState.IDLE
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
		car_state = CarState.IDLE
		await CameraTransition.transition_camera3D(camera_3d, car.camera_3d)
		GlobalVariables.isInDialogue = false
		set_physics_process(false)

func reset_wheel_rotations():
	car.front_left_wheel.rotation.y = 0
	car.front_right_wheel.rotation.y = 0

func start_reverse_movement():
	if car:
		initial_position = car.global_position
		car_state = CarState.REVERSING
		set_physics_process(true)

func _on_save_button_pressed():
	if car_state != CarState.ENTERING:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		animation_player.play_backwards("menu_opening")
		start_reverse_movement()
		current_selection = "wheels"
		update_specific_buttons()

func _on_cancel_button_pressed():
	if car_state != CarState.ENTERING:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		toggle_wheels(original_wheel)
		toggle_springs(original_spring)
		animation_player.play_backwards("menu_opening")
		start_reverse_movement()
		current_selection = "wheels"
		update_specific_buttons()

func toggle_wheels(wheel_index: int):
	if car:
		for pair in car.wheel_pairs:
			for i in range(len(car.wheel_pairs) - 1):
				pair[i].visible = (wheel_index == i)

func toggle_springs(spring_index: int):
	if car:
		for pair in car.spring_pairs:
			for i in range(len(car.spring_pairs) - 1):
				pair[i].visible = (spring_index == i)

func store_original_parts() -> void:
	if car:
		original_wheel = find_visible_index(car.wheel_pairs)
		original_spring = find_visible_index(car.spring_pairs)

func find_visible_index(pairs: Array) -> int:
	for pair in pairs:
		for i in range(pair.size()):
			if pair[i].visible:
				return i
	return 0

func _on_button_pressed():
	if current_selection == "wheels":
		toggle_wheels(0)
	elif current_selection == "spring":
		toggle_springs(0)

func _on_button_2_pressed():
	if current_selection == "wheels":
		toggle_wheels(1)
	elif current_selection == "spring":
		toggle_springs(1)

func _on_button_3_pressed():
	if current_selection == "wheels":
		toggle_wheels(2)
	elif current_selection == "spring":
		toggle_springs(2)

func _on_spring_pressed():
	current_selection = "spring"
	update_specific_buttons()

func _on_wheels_pressed():
	current_selection = "wheels"
	update_specific_buttons()

func update_specific_buttons():
	var button_text = "Spring" if current_selection == "spring" else "Wheel"
	for i in range(6):
		var button_node = specific_parts.get_node("Button" + ("" if i == 0 else str(i+1)))
		button_node.text = button_text + " " + str(i)
