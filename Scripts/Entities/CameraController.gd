extends Node3D

@onready var yaw_node = $CameraYaw
@onready var pitch_node = $CameraYaw/CameraPitch
@onready var camera = $CameraYaw/CameraPitch/SpringArm3D/Camera3D

var yaw: float = 0
var pitch: float = 0
var yaw_sensitivity: float = 0.07
var pitch_sensitivity: float = 0.07
var yaw_sensitivity_joystick: float = 2
var pitch_sensitivity_joystick: float = 2
var yaw_acceleration: float = 15
var pitch_acceleration: float = 15
var pitch_min: float = -55
var pitch_max: float = 75
var dragging = false
var axis_x = 0.0
var axis_y = 0.0

# Initial camera position
var initial_yaw: float = 0
var initial_pitch: float = 0

func _ready():
	# Store the initial camera position
	initial_yaw = yaw_node.rotation_degrees.y
	initial_pitch = pitch_node.rotation_degrees.x

func _input(event):
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT):
		dragging = event.pressed
	if event is InputEventMouseMotion and dragging:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += -event.relative.y * pitch_sensitivity
	if event is InputEventJoypadMotion:
		if event.axis == 2:  # Axe horizontal
			axis_x = event.axis_value
		elif event.axis == 3:  # Axe vertical
			axis_y = event.axis_value
	
	# Check for the reset camera input action
	if event.is_action_pressed("reset_camera"):
		reset_camera()
	
	pitch = clamp(pitch, pitch_min, pitch_max)

func _physics_process(delta):
	if abs(axis_x) > 0.1 or abs(axis_y) > 0.1:
		yaw += -axis_x * yaw_sensitivity_joystick
		pitch += -axis_y * pitch_sensitivity_joystick
	pitch = clamp(pitch, pitch_min, pitch_max)
	yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, yaw_acceleration * delta)
	pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, pitch_acceleration * delta)

func reset_camera():
	yaw = initial_yaw
	pitch = initial_pitch
