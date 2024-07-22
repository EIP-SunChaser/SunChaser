extends Control

@onready var workbench_menu = $"../WorkbenchMenu"
@onready var animation_player = $"../WorkbenchMenu/AnimationPlayer"
@onready var camera_3d = $"../Camera3D"
@onready var specific_parts = $LeftMenu/VBoxContainer/VBoxContainer/SpecificParts
@onready var wheels_button = $LeftMenu/VBoxContainer/VBoxContainer/CarParts/Wheels


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
		store_original_wheels()
		store_original_springs()
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
		await CameraTransition.transition_camera3D(camera_3d, car.camera_3d)
		GlobalVariables.isInDialogue = false
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
		animation_player.play_backwards("menu_opening")
		start_reverse_movement()
		current_selection = ""
		update_specific_buttons()

func _on_cancel_button_pressed():
	if !is_entering:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		toggle_wheels(original_wheel)
		toggle_springs(original_spring)
		animation_player.play_backwards("menu_opening")
		start_reverse_movement()
		current_selection = ""
		update_specific_buttons()

func toggle_wheels(wheel_index: int):
	if car:
		for pair in car.wheel_pairs:
			pair[0].visible = (wheel_index == 0)
			pair[1].visible = (wheel_index == 1)
			pair[2].visible = (wheel_index == 2)

func toggle_springs(spring_index: int):
	if car:
		for pair in car.spring_pairs:
			pair[0].visible = (spring_index == 0)
			pair[1].visible = (spring_index == 1)
			pair[2].visible = (spring_index == 2)


func store_original_wheels():
	if car:
		var index := 0
		for pair in car.wheel_pairs:
			if pair[index].visible == true:
				original_wheel = index
				return
			index += 1

func store_original_springs():
	if car:
		var index := 0
		for pair in car.spring_pairs:
			if pair[index].visible == true:
				original_spring = index
				return
			index += 1

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
	if current_selection == "spring":
		specific_parts.get_node("Button").text = "Spring 0"
		specific_parts.get_node("Button2").text = "Spring 1"
		specific_parts.get_node("Button3").text = "Spring 2"
		specific_parts.get_node("Button4").text = "Spring 3"
		specific_parts.get_node("Button5").text = "Spring 4"
		specific_parts.get_node("Button6").text = "Spring 5"
	elif current_selection == "wheels":
		specific_parts.get_node("Button").text = "Wheel 0"
		specific_parts.get_node("Button2").text = "Wheel 1"
		specific_parts.get_node("Button3").text = "Wheel 2"
		specific_parts.get_node("Button4").text = "Wheel 3"
		specific_parts.get_node("Button5").text = "Wheel 4"
		specific_parts.get_node("Button6").text = "Wheel 5"
