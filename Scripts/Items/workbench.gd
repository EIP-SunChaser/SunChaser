extends Area3D

@onready var workbench_menu = $"../WorkbenchMenu"

@export var WAIT_TIME = 0.5
@export var REVERSE_SPEED = 5.0
@export var REVERSE_DISTANCE = 10.0

var player_car
var timer: Timer
var initial_position: Vector3
var is_reversing = false

func _ready():
	timer = Timer.new()
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	add_child(timer)

func _on_body_entered(body):
	if body.is_in_group("JoltCar"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		workbench_menu.show()
		player_car = body
		timer.start(WAIT_TIME)

func _on_timer_timeout():
	if player_car:
		set_car_position()

func set_car_position():
	if player_car:
		player_car.parking_brake_engaged = true
		var new_position = Vector3(31, 0.5, -108)
		var new_rotation = Vector3(0, 0, 0)
		
		var new_transform = Transform3D(Basis().rotated(Vector3.UP, new_rotation.y), new_position)
		player_car.global_transform = new_transform
		player_car.linear_velocity = Vector3.ZERO

func _on_save_button_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	workbench_menu.hide()
	start_reverse_movement()
	
func _on_cancel_button_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	workbench_menu.hide()
	start_reverse_movement()

func start_reverse_movement():
	if player_car:
		player_car.parking_brake_engaged = false
		initial_position = player_car.global_position
		is_reversing = true
		set_physics_process(true)

func _physics_process(_delta):
	if player_car and is_reversing:
		var backward_direction = player_car.global_transform.basis.z
		player_car.linear_velocity = backward_direction * REVERSE_SPEED
		
		var distance_moved = player_car.global_position.distance_to(initial_position)
		if distance_moved >= REVERSE_DISTANCE:
			player_car.linear_velocity = Vector3.ZERO
			is_reversing = false
			set_physics_process(false)

func _on_button_pressed():
	for wheel_1 in player_car.wheel_1_meshs:
		wheel_1.show()
	for wheel_2 in player_car.wheel_2_meshs:
		wheel_2.hide()

func _on_button_2_pressed():
	for wheel_1 in player_car.wheel_1_meshs:
		wheel_1.hide()
	for wheel_2 in player_car.wheel_2_meshs:
		wheel_2.show()
