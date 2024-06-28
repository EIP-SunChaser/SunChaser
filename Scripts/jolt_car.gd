extends RigidBody3D

var active = false
var car_zone = false
var speed
@onready var camera_3d = $CameraRoot/CameraYaw/CameraPitch/SpringArm3D/Camera3D
@onready var speed_counter = $SpeedText/SpeedCounter
@export var suspension_length: float = 0.5
@export var spring_strength: float = 10
@export var spring_force: float = 1
@export var wheel_radius: float = 0.33
@export var engine_power: float
var accel_input = 0
var steering_input = 0
@export var steering_angle: float = 30.0
@export var steering_speed: float = 2.0
@export var front_tire_grip: float = 2.0
@export var rear_tire_grip: float = 2.0
@onready var multiplayer_synchronizer = $MultiplayerSynchronizer

var current_wheel_angle: float = 0.0

func _ready():
	multiplayer_synchronizer.set_multiplayer_authority(str(name).to_int())

func _physics_process(delta):
	if multiplayer_synchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		if active:
			accel_input = Input.get_axis("deccelerate", "accelerate")
			steering_input = Input.get_axis("right", "left")
			var target_steering_angle = steering_input * deg_to_rad(steering_angle)
			var front_left_wheel = $Wheels/FrontLeftWheel
			var front_right_wheel = $Wheels/FrontRightWheel
			
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
			camera_3d.make_current()
			leaving_car()
		else:
			$SpeedText.hide()
			entering_car()

# Le reste du code reste inchangé
func _on_player_detect_body_entered(body):
	if multiplayer_synchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		car_zone = true

func _on_player_detect_body_exited(body):
	if multiplayer_synchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		car_zone = false

func find_player():
	var character_bodies = get_tree().get_nodes_in_group("players")
	for body in character_bodies:
		if body is CharacterBody3D:
			return body
	return null

func entering_car():
	if Input.is_action_just_pressed("use") && car_zone:
		var player = find_player()
		if player:
			active = true
			player.visible = false
			player.set_physics_process(false)
			player.set_process_input(false)
			camera_3d.make_current()
			$SpeedText.show()

func leaving_car():
	var vehicle = self
	var player = find_player()
	if Input.is_action_just_pressed("use") && active:
		if player:
			var exit_location = vehicle.global_transform.origin - 2 * vehicle.global_transform.basis.x
			player.global_transform.origin = exit_location
			player.visible = true
			player.set_physics_process(true)
			player.set_process_input(true)
		active = false
		$SpeedText.hide()
