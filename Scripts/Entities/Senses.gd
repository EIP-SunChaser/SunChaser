extends Area3D
class_name AISenses

var angle_cone_of_vision := deg_to_rad(170.0)
var max_view_distance := 20.0
var angle_between_rays := deg_to_rad(3.3)

@onready var parent : CharacterBody3D = get_parent()

@export var current_enemies : Array[CharacterBody3D] = []

@export var check_los : bool = false

var raycast :RayCast3D

func _ready():
	generate_raycasts()
	
func generate_raycasts() -> void:
	var ray_count := angle_cone_of_vision / angle_between_rays
	var grandparent = get_parent()
	
	for index in ray_count:
		var ray := RayCast3D.new()
		var angle:= angle_between_rays * (index - ray_count / 2.0)
		var forward_dir := Vector3(0, 0, -1).rotated(Vector3.UP, angle)
		
		ray.debug_shape_thickness = 1
		ray.debug_shape_custom_color = Color(1, 1, 0, 1)
		ray.exclude_parent = true
		ray.add_exception(grandparent)
		ray.target_position = forward_dir * max_view_distance
		add_child(ray)
		ray.enabled = true
		
func _physics_process(delta: float) -> void:
	var bodies : Array[Node3D] = self.get_overlapping_bodies()
	
	if bodies.size() <= 1:
		return
	for ray in get_children():
		if ray is RayCast3D and ray.is_colliding():
			var collider = ray.get_collider()
			if parent == null or collider == null:
				return  # Stop execution if parent is null
			if parent.is_in_group("Ally") and collider.is_in_group("Enemy"):
				if collider not in current_enemies:
					current_enemies.append(collider)
			elif parent.is_in_group("Enemy") and (collider.is_in_group("Ally") or collider.is_in_group("Players")):
				if collider not in current_enemies:
					current_enemies.append(collider)
			break
			
func has_enemies() -> bool:
	if current_enemies.size() > 0:
		return true
	else:
		return false
		
func get_enemy() -> Node3D:
	if current_enemies.size() > 0:
		if check_los:
			if has_los(current_enemies[0].global_position):
				return current_enemies[0] as Node3D
			else:
				return null
		else:
			return current_enemies[0] as Node3D
	else:
		return null
		
func has_los(target : Vector3) -> bool:
	raycast.enabled = true
	raycast.look_at_from_position(raycast.global_position, target, Vector3(0,1,0))
	raycast.target_position.z = -raycast.global_position.distance_to(target)
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		raycast.enabled = false
		return false
	else:
		raycast.enabled = false
		return true

func _on_body_entered(body):
	pass #In future optimisation will activate senses only if there is something to see

func _on_body_exited(body):
	current_enemies.erase(body)
	parent.enemy = null
	parent.rotate_target = Vector3.ZERO
	parent.rotate_node = null
