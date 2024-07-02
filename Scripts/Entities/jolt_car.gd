extends RigidBody3D

var active = false
var car_zone = false
@export var speed = 0
@onready var camera_3d = $CameraRoot/CameraYaw/CameraPitch/SpringArm3D/Camera3D
@onready var speed_counter = $SpeedText/SpeedCounter
@export var suspension_length: float = 0.5
@export var spring_strength: float = 10
@export var spring_force: float = 1
@export var wheel_radius: float = 0.33
@export var engine_power: float
@export var accel_input = 0
@export var steering_input = 0
@export var steering_angle: float = 30.0
@export var steering_speed: float = 2.0
@export var front_tire_grip: float = 2.0
@export var rear_tire_grip: float = 2.0
@onready var multiplayer_synchronizer = $MultiplayerSynchronizer
@export var current_wheel_angle: float = 0.0
var front_left_wheel
var front_right_wheel
var players_in_zone = []
var player_in_car = null

var is_resetting = false
var reset_rotation_speed = 1.5
var target_rotation: Basis

var parking_brake_engaged = false
@export var parking_brake_force: float = 1000.0

#func _enter_tree():
	#set_multiplayer_authority(multiplayer.get_unique_id())

func _ready():
	front_left_wheel = $Wheels/FrontLeftWheel
	front_right_wheel = $Wheels/FrontRightWheel

func _physics_process(delta):
	if active:
		if Input.is_action_just_pressed("brake"):
			toggle_parking_brake()
		
		accel_input = Input.get_axis("deccelerate", "accelerate")
		steering_input = Input.get_axis("right", "left")
		
		# Apply steering
		var target_steering_angle = steering_input * deg_to_rad(steering_angle)
		var angle_difference = target_steering_angle - current_wheel_angle
		var max_angle_change = steering_speed * delta
		
		if abs(angle_difference) < max_angle_change:
			current_wheel_angle = target_steering_angle
		else:
			current_wheel_angle += sign(angle_difference) * max_angle_change
		
		current_wheel_angle = clamp(current_wheel_angle, -deg_to_rad(steering_angle), deg_to_rad(steering_angle))
		
		front_left_wheel.rotation.y = current_wheel_angle
		front_right_wheel.rotation.y = current_wheel_angle
		
		speed = int(linear_velocity.length())
		speed_counter.text = str(speed)
		$SpeedText.show()
		leaving_car()
		
		if Input.is_action_just_pressed("reset_car"):
			reset_car_rotation()
		
		apply_smooth_rotation(delta)
	else:
		$SpeedText.hide()
		entering_car()
		accel_input = 0
		front_left_wheel.rotation.y = 0
		front_right_wheel.rotation.y = 0

func toggle_parking_brake():
	parking_brake_engaged = !parking_brake_engaged

func _on_player_detect_body_entered(body):
	if body.is_in_group("Player"):
		players_in_zone.append(body)
		car_zone = true

func _on_player_detect_body_exited(body):
	if body.is_in_group("Player"):
		players_in_zone.erase(body)
		car_zone = players_in_zone.size() > 0

func find_local_player():
	for player in players_in_zone:
		if player.is_multiplayer_authority():
			return player
	return null

func entering_car():
	if Input.is_action_just_pressed("use") and car_zone and not active:
		var local_player = find_local_player()
		print(local_player)
		if local_player:
			set_player_in_car.rpc(local_player.get_path())

@rpc("any_peer", "call_local")
func set_player_in_car(player_path: NodePath):
	var player = get_node(player_path)
	if player:
		active = true
		$SpeedText.show()
		player.hide()
		player_in_car = player
		player_in_car.is_in_car = true
		player.set_collision_layer(0)
		
		var player_camera = player.get_node("Camera3D")
		if player_camera:
			player_camera.current = false
		
		if player.is_multiplayer_authority():
			camera_3d.current = true

func leaving_car():
	if Input.is_action_just_pressed("use") && active:
		remove_player_from_car.rpc()

@rpc("any_peer", "call_local")
func remove_player_from_car():
	if player_in_car:
		var exit_location = global_transform.origin - 2 * global_transform.basis.x
		player_in_car.global_transform.origin = exit_location
		player_in_car.show()
		player_in_car.set_collision_layer(1)
		
		var player_head = player_in_car.get_node("Head")
		var player_camera = player_head.get_node("Camera3D")
		
		if player_camera:
			player_camera.current = true
			camera_3d.current = false
		
		player_in_car.is_in_car = false
		player_in_car = null
	
	active = false
	$SpeedText.hide()

func is_car_upside_down():
	return global_transform.basis.y.dot(Vector3.UP) < 0

func reset_car_rotation():
	if is_car_upside_down() and not is_resetting:
		is_resetting = true
		var current_position = global_transform.origin
		target_rotation = global_transform.basis.rotated(global_transform.basis.z, PI)
		global_transform.origin = current_position + Vector3(0, 1, 0)

func apply_smooth_rotation(delta):
	if is_resetting:
		var current_rotation = global_transform.basis
		var new_rotation = current_rotation.slerp(target_rotation, reset_rotation_speed * delta)
		global_transform.basis = new_rotation
		
		if current_rotation.y.dot(Vector3.UP) >= global_transform.basis.y.dot(Vector3.UP):
			is_resetting = false
