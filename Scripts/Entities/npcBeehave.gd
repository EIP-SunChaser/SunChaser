extends RigidBody3D

var health = 100

var is_alive := true
var gravity : Vector3
var custom_gravity : Vector3 = Vector3.ZERO
var on_ground : bool

var rotate_self := true
var rotate_target : Vector3 = Vector3.ZERO
var rotate_node : Node3D = null

var last_frame_velocity : Vector3
var ground_check : Area3D

var near_obstacle : bool = false
var obstacle_distance : Vector3

var nav_unstuck_active := false

# Uses a ground check child node to check for the floor, more accurate
@export var use_groundcheck : bool = false

@export var max_wander_distance := 10.0
@export var wander_radius := 5.0
@export var obstacle_path_skip_distance : float = 1.5
@export var ground_detection_sensitivity : float = 3

@export var normal_friction := 0.5
@export var slide_friction := 1
@export var in_air_downward_force := 0.0

@export var normal_speed := 3.0
@export var acceleration := 5.0
@export var turn_speed := 5.0

@export var enable_slide := false

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

@onready var start_path_desired_distance = nav_agent.path_desired_distance

@onready var movement_speed := normal_speed

@onready var start_position : Vector3 = global_position

# Only used if GroundCheck is disabled
@export var floor_layer_mask := 0b0001 ## This is in Binary

var enable_navigation := true
var nav_force : Vector3

func _on_body_part_hit(dam):
	health -= dam
	if health <= 0:
		if is_in_group("Bandits"):
			GlobalVariables.entity_kill += 1
			if GlobalVariables.entity_kill >= 3:
				if GlobalVariables.quest_one == GlobalVariables.check_quest.KILL_RED_TWO:
					GlobalVariables.quest_one = GlobalVariables.check_quest.TALK_FORESTIERS_ONE
			else:
				if GlobalVariables.quest_one == GlobalVariables.check_quest.KILL_RED_TWO:
					GlobalVariables.quest_one = GlobalVariables.check_quest.KILL_RED_ONE
		queue_free()
		
func _physics_process(_delta):
	# reset gravity scale if it was changed
	gravity_scale = 1

	_check_out_of_bounds()

	if !is_alive:
		return

	_is_on_ground()
	
	if custom_gravity != Vector3.ZERO:
		gravity = custom_gravity
	else:
		gravity = PhysicsServer3D.body_get_direct_state(get_rid()).total_gravity
	# if the gravity is upward, meaning you are in a wind zone,
	# then pretend you aren't on the ground.
	# without this enemies stick to the ground even in wind zones
	if custom_gravity != Vector3.ZERO:
		on_ground = false
		if custom_gravity.y > 0:
			gravity_scale = 0.0
		
	elif enable_navigation and on_ground:			
		_navigate(_delta)
		
		# if you are trying to move up, disable gravity. This reduces agents being stuck on slopes
		if linear_velocity.y > 0.0:
			gravity_scale = 1
		else:
			gravity_scale = 1;
		
		
	elif on_ground and enable_slide:
		physics_material_override.set("friction", slide_friction)
	else:
		
		# if you are in a wind area, fake being heavy by having it affect you less.
		if linear_velocity.y > 4 and false:
			nav_force += Vector3(0, -in_air_downward_force * _delta, 0)
			
		apply_central_force(custom_gravity)

	if rotate_self:
		if rotate_node != null:
			rotate_target = rotate_node.global_position
		elif enable_navigation:
			rotate_target = nav_agent.get_next_path_position()
		_rotate_towards(rotate_target, _delta)
		
	linear_velocity += gravity * _delta
	
	last_frame_velocity = linear_velocity

### --- Interal Functions --- ###

# sets on_ground
func _is_on_ground():
	
	on_ground = true

# if the physics bugs and the slime falls out of the world or goes flying this will reset them, prevents the game from crashing
func _check_out_of_bounds():
	if global_position.distance_to(start_position) > 100:
		global_position = start_position
		linear_velocity = Vector3.ZERO
		printerr("POSITION RESET of ", self.name)
		return
		
func _navigate(_delta):

	if is_at_destination():
		toggle_navigation(false)
		return

	if nav_agent.is_navigation_finished():
		linear_velocity = Vector3.ZERO
		nav_force = Vector3.ZERO
		return

	# calculate movement
	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	var current_agent_position: Vector3 = global_position

	# set the acceleration
	var _speed = nav_force.length()
	
	if nav_force.length() < movement_speed:
		_speed = move_toward(nav_force.length(), movement_speed, (acceleration * 1) * _delta)

	var new_vector: Vector3 = (next_path_position - current_agent_position).normalized()

	# If the path_desired_distance was changed, change it back
	if nav_agent.path_desired_distance != start_path_desired_distance: nav_agent.path_desired_distance = start_path_desired_distance

	# if you detect an obstacle, call avoid_obstacle
	if near_obstacle:
		new_vector = _avoid_obstacle(new_vector, next_path_position)

	# apply speed to the normalized vector
	var new_velocity = new_vector * _speed

	rotate_target = next_path_position

	apply_nav_velocity(new_velocity)
	
func apply_nav_velocity(safe_velocity: Vector3):
	# make sure linear velocity cannot be more than movement speed
	# but exclude y velocity as to not affect falling
	if safe_velocity.length() > movement_speed:
		var _y = linear_velocity.y
		linear_velocity = safe_velocity.normalized() * movement_speed
		linear_velocity.y = _y
		
	else:
		nav_force = safe_velocity
		linear_velocity = Vector3(nav_force.x, nav_force.y, nav_force.z)	

func _rotate_towards(_pos : Vector3, _delta : float):

	# optional, this makes the agent not rotate vertically
	_pos.y = global_position.y

	if global_transform.origin.is_equal_approx(_pos) or _pos == Vector3.ZERO:
		return

	# smoothly rotate to look at next_path_position (I dont know how it works)
	# from reddit user u/NovemberDev
	# this is done before collision detection because if you dont, it spins in a circle around the obstacle
	global_transform.basis = global_transform.basis.slerp(global_transform.looking_at(_pos, Vector3.UP).basis, _delta * turn_speed)
	
func _avoid_obstacle(_v3 : Vector3, _next_pos : Vector3) -> Vector3:
	var left_velocity = _v3.rotated(Vector3(0,1,0), PI/2)
	var right_velocity = _v3.rotated(Vector3(0,1,0), -PI/2)

	if obstacle_distance.x > obstacle_distance.z: # if there's a closer collion on the left, go right
		_v3 = _v3.lerp(right_velocity, obstacle_distance.x).normalized()
	elif obstacle_distance.z > obstacle_distance.x: # if there's a closer collion on the right, go left
		_v3 = _v3.lerp(left_velocity, obstacle_distance.z).normalized()
	elif obstacle_distance.length() > 0: # if they are equal or only the middle is colliding, go left by default
		_v3 = _v3.lerp(left_velocity, obstacle_distance.y).normalized()

	# if the final destination is inside the obstacle, unstuck yourself
	if global_position.distance_to(nav_agent.get_final_position()) < obstacle_path_skip_distance:
		_nav_unstuck()

	# if the path position is close and you are hitting an obstacle, it is likely inside the obstacle, so skip it
	elif global_position.distance_to(_next_pos) < obstacle_path_skip_distance:
		#print("next nav point inside obstacle, skipping...")
		nav_agent.path_desired_distance = obstacle_path_skip_distance

	# reset obstacle_distance and near_obstacle
	obstacle_distance = Vector3.ZERO
	near_obstacle = false
	return _v3
	
func _nav_unstuck():
	# you cant set a target while unstuck is active so turn it off
	nav_unstuck_active = false
		
# Behavior Tree #

func is_at_destination() -> bool:
	# This optional step can prevent lag in some rare cases
	# but it also causes issues where the agents will just sit and do nothing
	#if !nav_agent.is_target_reachable():
	#	return true
	if nav_agent.is_target_reached():
		return true
	else:
		return false
		
func toggle_navigation(b : bool):
	enable_navigation = b
	
	if b == false:
		nav_force = Vector3.ZERO
		if !enable_slide:
			linear_velocity = Vector3.ZERO
		
# The below functions are used to replicate the functionality of Unity's RandomOnUnitCircle
# which is used for the enemy wander state.
func RandomOnUnitCircleV3():
	var _v2 = RandomOnUnitCircle()
	return Vector3(_v2.x, 0, _v2.y)

func RandomOnUnitCircle():
	var _rV3 : Vector3 = RandomVector3().normalized()
	var _rV2 : Vector2 = Vector2(_rV3.x, _rV3.y)
	var _angle : Vector2 = Vector2.ZERO.direction_to(_rV2)
	return _angle
	
func RandomVector3():
	var x0 : float = -1.0 + randf() * 2.0
	var x1 : float = -1.0 + randf() * 2.0
	var x2 : float = -1.0 + randf() * 2.0
	var x3 : float = -1.0 + randf() * 2.0
	while x0 * x0 + x1 * x1 + x2 * x2 + x3 * x3 >= 1:
		x0 = -1.0 + randf() * 2.0
		x1 = -1.0 + randf() * 2.0
		x2 = -1.0 + randf() * 2.0
		x3 = -1.0 + randf() * 2.0
	var a : float = x0*x0*x1*x1+x2*x2+x3*x3
	var x : float = 2*(x1 * x3+x0*x2)/a
	var y : float = 2*(x2*x3-x0*x1)/a
	var z : float = (x0*x0 + x3*x3 - x1*x1 - x2*x2)/a
	return Vector3(x,y,z)

func new_wander_target(_radius : float = wander_radius):
	set_target((RandomOnUnitCircleV3() * _radius) + global_position)

func set_target(_target: Vector3):
	# get position of the target
	var _pos : Vector3 = _target

	# get the nav map and then find the closest point on the map to the slime target
	var map = nav_agent.get_navigation_map()

	var _navmesh_pos = NavigationServer3D.map_get_closest_point(map, _pos)

	nav_agent.target_position = _navmesh_pos
