extends CharacterBody3D

var health = 100

@export var movement_speed: float = 4.0
@export var target_radius: float = 10.0  # Radius around the character to find a target
@export var rotation_speed: float = 3.0  # Speed at which the character rotates toward the target

@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")

var rotate_target : Vector3 = Vector3.ZERO
var rotate_node : Node3D = null

func _physics_process(delta):
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	
	if rotate_node != null:
		rotate_target = rotate_node.global_position
	else:
		rotate_target = next_path_position
	look_in_direction(rotate_target, delta)
	
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
		
func look_in_direction(target_position: Vector3, delta: float) -> void:
	var direction: Vector3 = target_position - global_position
	direction.y = 0  # Ignore the Y axis to ensure the character looks horizontally
	if direction.length() > 0.01:  # Only rotate if there's actual movement
		direction = direction.normalized()
		var target_rotation: Vector3 = direction.angle_to(Vector3.FORWARD) * Vector3.UP
		var target_transform: Transform3D = Transform3D().looking_at(direction, Vector3.UP)
		# Interpolating the rotation
		rotation = rotation.lerp(target_transform.basis.get_euler(), rotation_speed * delta)
		
func choose_random_target() -> void:
	var random_offset: Vector3 = get_random_point_in_radius()
	var target_position: Vector3 = global_position + random_offset
	set_movement_target(target_position)
	
func get_random_point_in_radius() -> Vector3:
	var angle: float = randf() * TAU  # TAU is a constant for 2*PI (full circle in radians)
	var distance: float = randf() * target_radius  # Random distance within the radius
	var x_offset: float = cos(angle) * distance
	var z_offset: float = sin(angle) * distance
	return Vector3(x_offset, 0, z_offset)  # Random point on the XZ plane
	
func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)
	
func is_at_destination():
	return navigation_agent.is_navigation_finished()

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()
	
func _on_body_part_hit(dam):
	health -= dam
	if health <= 0:
		queue_free()
