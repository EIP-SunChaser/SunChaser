extends CharacterBody3D

@export var health = 100

@onready var senses = $Senses
@onready var rifle = $Rifle

@export var pathFollow: PathFollow3D

#groupes by rapport of their relation with the player
@export_enum("Ally", "Neutral", "Enemy") var affiliation: String

@export var isFighter: bool

@export var movement_speed: float = 4.0
@export var target_radius: float = 10.0  # Radius around the character to find a target
@export var rotation_speed: float = 3.0  # Speed at which the character rotates toward the target

@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")

var rotate_target : Vector3 = Vector3.ZERO
var rotate_node : Node3D = null

var enemy : Node3D

#region Look Mecanic

func look_at_target(target_position: Vector3) -> void:
	var direction: Vector3 = (target_position - global_position).normalized()
	look_at(global_position + direction, Vector3.UP)  # Rotate the character towards the target position
	
# Smoothly rotate the character towards the movement direction
func look_in_direction(target_position: Vector3, delta: float) -> void:
	var direction: Vector3 = target_position - global_position
	direction.y = 0  # Ignore the Y axis to ensure the character looks horizontally
	if direction.length() > 0.01:  # Only rotate if there's actual movement
		direction = direction.normalized()
		
		# Get the current rotation as a basis
		var current_basis: Basis = basis
		# Create a new transform looking at the target direction
		var target_basis: Basis = Basis().looking_at(direction, Vector3.UP)
		
		# Use slerp to interpolate between current and target rotation smoothly
		basis = current_basis.slerp(target_basis, rotation_speed * delta)
#endregion

#region Movement System
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
	
func flee_from_target(target: Vector3):
	var flee_distance = 30.0
	# Get the direction vector from AI to target
	var direction_to_target: Vector3 = (target - global_transform.origin).normalized()
	# Invert the direction (opposite direction)
	var flee_direction: Vector3 = -direction_to_target
	# Calculate the flee position (some distance away)
	var flee_position: Vector3 = global_transform.origin + flee_direction * flee_distance
	
	# Set the flee position as the target destination for the NavigationAgent3D
	set_movement_target(flee_position)
	
func has_patrol() -> bool:
	return is_instance_valid(pathFollow)
	
func is_at_patrol() -> bool:
	var tolerance = 1.0
	if global_position.distance_to(pathFollow.global_position) < tolerance:
		return true
	return false

func return_to_patrol():
	set_movement_target(pathFollow.global_position)

func increment_patrol():
	pathFollow.progress += 1.0
	
func is_at_destination():
	return navigation_agent.is_navigation_finished()

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)
	
func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()
#endregion

#region Health System

func _on_body_part_hit(dam):
	health -= dam
	if health <= 0:
		queue_free()
		
#endregion

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	
	if affiliation == "Ally":
		add_to_group("Ally")
	elif affiliation == "Neutral":
		add_to_group("Neutral")
	elif affiliation == "Enemy":
		add_to_group("Enemy")
	else:
		add_to_group("Not Defined")
		
	if not isFighter:
		remove_child(get_node("Rifle"))

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

