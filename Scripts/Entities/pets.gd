extends CharacterBody3D

@export var movement_speed: float = 8.0
@export var follow_distance: float = 4.0
@onready var area_3d = $Area3D
@onready var animation_player = $AnimationPlayer
@export var rotation_speed: float = 5.0
var players_in_zone = []
var player = null
var target_position: Vector3 = Vector3()
var previous_player_position: Vector3 = Vector3()

func find_local_player():
	for p in players_in_zone:
		if p.is_multiplayer_authority():
			return p
	return null

func _physics_process(_delta):
	if player and area_3d.follow:
		var player_current_position = player.global_position
		if player_current_position != previous_player_position:
			var player_direction = (player_current_position - previous_player_position).normalized()
			var player_speed = (player_current_position - previous_player_position).length() / _delta
			previous_player_position = player_current_position
			target_position = player.global_position - (player_direction * follow_distance)
			
			var anim_name = "run_animation" if is_on_floor() else "jump_animation"
			var anim_speed = (player_speed / movement_speed) * 3.0 if is_on_floor() else 1.0
			play_animation.rpc(anim_name, anim_speed)
		else:
			play_animation.rpc("idle_animation", 1.0)
		
		var desired_velocity: Vector3 = global_position.direction_to(target_position) * movement_speed
		
		velocity = desired_velocity
		move_and_slide()
		var look_at_position = player.global_position
		look_at_position.y = global_position.y
		var target_transform = transform.looking_at(look_at_position, Vector3.UP)
		transform = transform.interpolate_with(target_transform, rotation_speed * _delta)
		
		update_state.rpc(global_position, velocity, transform)

@rpc("any_peer", "call_local")
func update_state(new_position: Vector3, new_velocity: Vector3, new_transform: Transform3D):
	global_position = new_position
	velocity = new_velocity
	transform = new_transform

@rpc("any_peer", "call_local")
func play_animation(anim_name: String, anim_speed: float):
	animation_player.play(anim_name)
	animation_player.set_speed_scale(anim_speed)

func _on_area_3d_body_entered(body):
	players_in_zone.append(body)
	player = find_local_player()

func _on_area_3d_body_exited(body):
	players_in_zone.erase(body)
