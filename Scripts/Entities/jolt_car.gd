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
var player_in_car: CharacterBody3D = null
var steering_enabled := true

var is_resetting = false
var reset_rotation_speed = 1.5
var target_rotation: Basis

var parking_brake_engaged = false
@export var parking_brake_force: float = 1000.0
var is_stationary = false

# Battery system variables
@export var max_battery: float = 100.0
@export var current_battery: float = 100.0
@export var battery_drain_rate: float = 0.1
@onready var battery_display = $BatteryText/BatteryBar
var is_being_charged = false

# Radio
@onready var radio_text = $RadioText
@onready var audio_stream_player_3d = $AudioStreamPlayer3D
@onready var audio_stream_player = $AudioStreamPlayer
@export var radio_on = false
@export var current_playback_position = 0.0

@onready var left_head_light = $HeadLight/LeftHeadLight
@onready var right_head_light = $HeadLight/RightHeadLight

@onready var left_tail_light = $TailLight/LeftTailLight
@onready var right_tail_light = $TailLight/RightTailLight
var left_tail_light_material: StandardMaterial3D
var right_tail_light_material: StandardMaterial3D

var red_color = Color(1, 0, 0, 1)
var white_color = Color(0.646, 0.646, 0.646, 1)

func save_data(data: SaveData):
	data.car_position = position
	data.car_rotation = rotation
	data.car_battery = current_battery

func load_data(data: SaveData):
	position = data.car_position
	rotation = data.car_rotation
	current_battery = data.car_battery

@export var wheel_meshs: Array[Mesh]
@export var spring_meshs: Array[Mesh]

var current_wheel_index: int = 0
var current_spring_index: int = 0

const WHEEL_NAMES = ["FrontLeftWheel", "FrontRightWheel", "BackLeftWheel", "BackRightWheel"]

# TODO rename Wheels node to be more accurate
func set_mesh(mesh_array: Array[Mesh], index: int, part_name: String) -> void:
	if index < 0 or index >= mesh_array.size():
		print("Invalid %s mesh index" % [part_name])
		return

	for wheel in WHEEL_NAMES:
		var mesh_node = get_node("Wheels/%s/%s/Mesh" % [wheel, part_name])
		if mesh_node:
			mesh_node.mesh = mesh_array[index]

@rpc("any_peer", "call_local")
func set_wheel_mesh(index: int) -> void:
	set_mesh(wheel_meshs, index, "Wheel")
	current_wheel_index = index
@rpc("any_peer", "call_local")
func set_spring_mesh(index: int) -> void:
	set_mesh(spring_meshs, index, "Spring")
	current_spring_index = index

func init_spring_meshs() -> void:
	for mod_name in ModLoader.modded_wheels:
		wheel_meshs.append_array(ModLoader.modded_wheels[mod_name])

	for mod_name in ModLoader.modded_springs:
		spring_meshs.append_array(ModLoader.modded_springs[mod_name])

func _ready():
	front_left_wheel = $Wheels/FrontLeftWheel
	front_right_wheel = $Wheels/FrontRightWheel
	left_tail_light_material = left_tail_light.get_active_material(0)
	right_tail_light_material = right_tail_light.get_active_material(0)
	init_spring_meshs()

func _physics_process(delta):
	if !is_multiplayer_authority(): return

	if active && !GlobalVariables.isInPause && !GlobalVariables.isInDialogue:
		if Input.is_action_just_pressed("brake"):
			toggle_parking_brake()

		if Input.is_action_just_pressed("radio"):
			radio()
		if steering_enabled:
			steering_input = Input.get_axis("right", "left")

		if current_battery > 0:

			accel_input = Input.get_axis("deccelerate", "accelerate")
			if not is_being_charged and not is_stationary:
				current_battery -= battery_drain_rate * delta * abs(accel_input)
				current_battery = max(current_battery, 0)
		else:
			accel_input = 0

		if parking_brake_engaged:
			if speed == 0:
				is_stationary = true
				linear_velocity.z = 0
				if abs(linear_velocity.y) < 0.1:
					linear_velocity.y = 0
					linear_velocity.x = 0
		else:
			is_stationary = false

		update_tail_lights()

		if player_in_car.is_in_car:
			player_in_car.head.global_transform.basis = camera_3d.global_transform.basis
			player_in_car.camera.global_transform.basis = camera_3d.global_transform.basis
			player_in_car.rotation = self.rotation
			player_in_car.global_transform.origin = self.global_transform.origin


		# Apply steering (allowed even with depleted battery)
		var target_steering_angle = steering_input * deg_to_rad(steering_angle)
		var angle_difference_weel = target_steering_angle - current_wheel_angle
		var max_angle_change = steering_speed * delta

		if abs(angle_difference_weel) < max_angle_change:
			current_wheel_angle = target_steering_angle
		else:
			current_wheel_angle += sign(angle_difference_weel) * max_angle_change

		current_wheel_angle = clamp(current_wheel_angle, -deg_to_rad(steering_angle), deg_to_rad(steering_angle))

		front_left_wheel.rotation.y = current_wheel_angle
		front_right_wheel.rotation.y = current_wheel_angle

		speed = int(linear_velocity.length())
		speed_counter.text = str(speed)
		$SpeedText.show()

		battery_display.battery = current_battery
		$BatteryText.show()
		$RadioText.show()
		leaving_car()

		if Input.is_action_just_pressed("reset_car"):
			reset_car_rotation()

		if Input.is_action_just_pressed("teleport"):
			global_transform.origin = Vector3(-14, 5, 1)
			self.set_global_rotation_degrees(Vector3(0, 90, 0))

		if Input.is_action_just_pressed("teleport-2"):
			global_transform.origin = Vector3(-1220, 20, -15)
			self.set_global_rotation_degrees(Vector3(0, -90, 0))

		if Input.is_action_just_pressed("teleport-3"):
			global_transform.origin = Vector3(-230, 20, -10)
			self.set_global_rotation_degrees(Vector3(0, -90, 0))

		if Input.is_action_just_pressed("headlight"):
			left_head_light.visible = !left_head_light.visible
			right_head_light.visible = !right_head_light.visible
	else:
		$SpeedText.hide()
		$BatteryText.hide()
		$RadioText.hide()
		entering_car()
		accel_input = 0
		front_left_wheel.rotation.y = 0
		front_right_wheel.rotation.y = 0

	apply_smooth_rotation(delta)

func update_tail_lights():
	var braking = Input.is_action_pressed("deccelerate")
	var reversing = linear_velocity.dot(-global_transform.basis.z) > 0
	var emission_color: Color

	if braking:
		emission_color = red_color if reversing else white_color
	sync_tail_lights.rpc(braking, emission_color)

@rpc("any_peer", "call_local")
func sync_tail_lights(braking: bool, emission_color: Color):
	left_tail_light_material.emission_enabled = braking
	right_tail_light_material.emission_enabled = braking
	left_tail_light_material.emission = emission_color
	right_tail_light_material.emission = emission_color

func toggle_parking_brake():
	parking_brake_engaged = !parking_brake_engaged

func _on_player_detect_body_entered(body):
	players_in_zone.append(body)
	car_zone = true

func _on_player_detect_body_exited(body):
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
		if local_player:
			if is_car_upside_down() and not is_resetting:
				reset_car_rotation()
			else:
				set_player_in_car.rpc(local_player.get_path())

@rpc("any_peer", "call_local")
func set_player_in_car(player_path: NodePath):
	if !is_multiplayer_authority(): return
	var player = get_node(player_path)
	if player:
		active = true
		$SpeedText.show()
		$BatteryText.show()
		player_in_car = player
		if not player_in_car.is_crouching:
			player_in_car.crouch.rpc()
		player_in_car.pseudo.hide()
		player_in_car.is_in_car = true

		if player.is_multiplayer_authority():
			await CameraTransition.transition_camera3D(player_in_car.camera, camera_3d, 0.5)
			update_radio_for_player()

func leaving_car():
	if Input.is_action_just_pressed("use") && active:
		remove_player_from_car.rpc()

@rpc("any_peer", "call_local")
func remove_player_from_car():
	if player_in_car:
		var exit_location = global_transform.origin - 3.5 * global_transform.basis.x
		player_in_car.global_transform.origin = exit_location
		player_in_car.show()

		var player_head = player_in_car.get_node("Head")
		var player_camera = player_head.get_node("Camera3D")

		if player_camera && player_camera.is_multiplayer_authority():
			await CameraTransition.transition_camera3D(camera_3d, player_in_car.camera, 0.5)

		player_in_car.is_in_car = false
		player_in_car.crouch.rpc()
		player_in_car.rotation = Vector3.ZERO
		player_in_car.global_transform.origin.x = self.global_transform.origin.x + 4
		player_in_car.pseudo.show()
		player_in_car = null
		update_radio_for_player()

	active = false
	$SpeedText.hide()
	$BatteryText.hide()
	$RadioText.hide()

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

		if abs(new_rotation.y.dot(Vector3.UP) - 1.0) < 0.01:
			is_resetting = false

func recharge_battery(amount: float):
	is_being_charged = true
	current_battery = min(current_battery + amount, max_battery)
	battery_display.battery = current_battery

func radio():
	radio_on = !radio_on
	if radio_on:
		if player_in_car and player_in_car.is_multiplayer_authority():
			audio_stream_player.play(current_playback_position)
			audio_stream_player_3d.stop()
		else:
			audio_stream_player.stop()
			audio_stream_player_3d.play(current_playback_position)
	else:
		current_playback_position = audio_stream_player.get_playback_position() if audio_stream_player.playing else audio_stream_player_3d.get_playback_position()
		audio_stream_player.stop()
		audio_stream_player_3d.stop()

func update_radio_for_player():
	if radio_on:
		current_playback_position = audio_stream_player.get_playback_position() if audio_stream_player.playing else audio_stream_player_3d.get_playback_position()
		if player_in_car and player_in_car.is_multiplayer_authority():
			audio_stream_player.play(current_playback_position)
			audio_stream_player_3d.stop()
		else:
			audio_stream_player.stop()
			audio_stream_player_3d.play(current_playback_position)
