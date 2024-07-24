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
var current_selection = "wheels"
var original_wheel_index: int = 0
var original_spring_index: int = 0
var total_wheels = []
var total_springs = []

func _on_area_3d_body_entered(body):
	if !is_multiplayer_authority() or !body.is_in_group("JoltCar") or !body.active:
		return

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GlobalVariables.isInDialogue = true
	workbench_menu.show()
	wheels_button.grab_focus()
	animation_player.play("menu_opening")

	car = body
	if car:
		total_wheels.clear()
		total_springs.clear()
		
		for mesh in car.wheel_meshs:
			total_wheels.append(mesh)
		for mesh in car.spring_meshs:
			total_springs.append(mesh)

	car.linear_velocity = Vector3.ZERO
	store_original_parts()
	initialize_enter_movement()

func _physics_process(_delta):
	if !car: return
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

	var current_rotation = car.global_transform.basis.get_euler()
	current_rotation.y = lerp(current_rotation.y, target_rotation.y, rotation_speed)
	car.global_transform = Transform3D(Basis().rotated(Vector3.UP, current_rotation.y), car.global_position)

	var forward_direction = -car.global_transform.basis.z.normalized()
	car.linear_velocity = forward_direction * enter_speed

	if car.global_position.distance_to(initial_position) >= enter_distance:
		car.linear_velocity = Vector3.ZERO
		car_state = CarState.IDLE
		set_physics_process(false)

func update_reverse_movement():
	reset_wheel_rotations()

	var backward_direction = Vector3(0, 0, 1)
	car.linear_velocity = backward_direction * reverse_speed

	if car.global_position.distance_to(initial_position) >= reverse_distance:
		workbench_menu.hide()
		car.linear_velocity = Vector3.ZERO
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

func _on_save_button_pressed() -> void:
	if car_state != CarState.ENTERING:
		close_workbench()

func _on_cancel_button_pressed() -> void:
	if car_state != CarState.ENTERING:
		car.set_wheel_mesh(original_wheel_index)
		car.set_spring_mesh(original_spring_index)
		close_workbench()

func close_workbench() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animation_player.play_backwards("menu_opening")
	start_reverse_movement()
	current_selection = "wheels"
	update_specific_buttons()

func store_original_parts() -> void:
	if car:
		original_wheel_index = car.current_wheel_index
		original_spring_index = car.current_spring_index

func _on_specific_button_pressed(index: int):
	if current_selection == "wheels":
		car.set_wheel_mesh.rpc(index)
	elif current_selection == "spring":
		car.set_spring_mesh.rpc(index)

func _on_spring_pressed():
	current_selection = "spring"
	update_specific_buttons()

func _on_wheels_pressed():
	current_selection = "wheels"
	update_specific_buttons()

func update_specific_buttons():
	for child in specific_parts.get_children():
		child.queue_free()
	
	var button_text = "Spring" if current_selection == "spring" else "Wheel"
	var array = total_springs if current_selection == "spring" else total_wheels
	for i in range(array.size()):
		var new_button = Button.new()
		new_button.custom_minimum_size = Vector2(100, 100)
		new_button.pressed.connect(_on_specific_button_pressed.bind(i))
		
		var icon_path = get_icon_path(array[i])
		if icon_path != "" and ResourceLoader.exists(icon_path):
			var icon_texture = load(icon_path)
			new_button.icon = icon_texture
			new_button.expand_icon = true
		else: 
			new_button.text = button_text + " " + str(i)
		specific_parts.add_child(new_button)

func get_icon_path(mesh_resource: Resource) -> String:
	var mesh_name = mesh_resource.resource_path.get_file().get_basename()
	var icon_base_path = "Assets/Icons/Car/Parts/"
	
	match current_selection:
		"spring":
			return icon_base_path + "Springs/" + mesh_name + ".png"
		"wheels":
			return icon_base_path + "Wheels/" + mesh_name + ".png"
		_:
			return ""
