extends RayCast3D

@onready var car: RigidBody3D = get_parent().get_parent()
@onready var wheel = $Wheel

var previous_spring_length: float = 0.0

@export var is_front_wheel: bool

func _ready():
	add_exception(car)

func _physics_process(delta):
	var collision_point = get_collision_point()
	if is_colliding():
		suspension(delta, collision_point)
		acceleration(collision_point)
		
		apply_z_force(collision_point)
		apply_x_force(delta, collision_point)
		
		set_wheel_postion(to_local(get_collision_point()).y + car.wheel_radius)
	else:
		set_wheel_postion(-car.suspension_length)

	rotate_wheel(delta)
		
func apply_z_force(collision_point):
	var dir: Vector3 = global_basis.z
	var state := PhysicsServer3D.body_get_direct_state(car.get_rid())
	var tire_velocity := state.get_velocity_at_local_position(global_position - car.global_position)
	var z_force = dir.dot(tire_velocity) * car.mass / 15
		
	car.apply_force(-dir * z_force, collision_point - car.global_position)

func apply_x_force(delta, collision_point):
	var dir: Vector3 = global_basis.x
	var state := PhysicsServer3D.body_get_direct_state(car.get_rid())
	var tire_velocity := state.get_velocity_at_local_position(global_position - car.global_position)
	var lateral_velocity: float = dir.dot(tire_velocity)
	var grip = car.rear_tire_grip
	
	if is_front_wheel:
		grip = car.front_tire_grip
	
	var desired_velocity_change = -lateral_velocity * grip
	var x_force = desired_velocity_change / delta
	car.apply_force(dir * x_force, collision_point - car.global_position)
	
func set_wheel_postion(new_y_position: float):
	wheel.position.y = lerp(wheel.position.y, new_y_position, 0.6)
	
func rotate_wheel(delta: float):
	var dir = car.basis.z
	var rotation_direction = 1 if car.linear_velocity.dot(dir) > 0 else - 1
	
	wheel.rotate_x(rotation_direction * car.linear_velocity.length() * delta)
		
func acceleration(collision_point):
	if is_front_wheel:
		return
	var accel_dir = -global_basis.z
	
	var torque = car.accel_input * car.engine_power
	
	var point = Vector3(collision_point.x, collision_point.y + car.wheel_radius, collision_point.z)
	car.apply_force(accel_dir * torque, point - car.global_position)

func suspension(delta, collision_point):
		
	var suspension_dir = global_basis.y
	
	var raycast_origin = global_position	
	var raycast_dest = collision_point
	var distance = raycast_dest.distance_to(raycast_origin)
	
	var contact = collision_point - car.global_position
	
	var spring_length = clamp(distance - car.wheel_radius, 0, car.suspension_length)
	
	# spring compression
	var spring_force = car.spring_strength * (car.suspension_length - spring_length)
	
	var spring_velocity = (previous_spring_length - spring_length) / delta
	
	var damper_force = car.spring_force * spring_velocity
	
	var suspension_force = basis.y * (spring_force + damper_force)
	
	previous_spring_length = spring_length
	
	# Point where the force is applied
	var point = Vector3(raycast_dest.x, raycast_dest.y + car.wheel_radius, raycast_dest.z)
	
	car.apply_force(suspension_dir * suspension_force, point - car.global_position)
