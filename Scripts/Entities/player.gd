extends CharacterBody3D

@onready var camera = $Head/Camera3D
@onready var head = $Head
@onready var animation_player = $AnimationPlayer
@onready var pseudo = $Pseudo
@onready var actionable_finder: Area3D = $Area3D
@onready var deathLabel = $"Head/Camera3D/DeathLabel"
@onready var health_bar = $Head/Camera3D/HealthBar

@onready var pause_menu = $pause_menu
var paused = false
var game_paused = false  # New variable to track game pause state

#Bullets
@onready var gun_animation = $"Head/Camera3D/rifle_prototype/AnimationPlayer"
@onready var bullet_sound = $"Head/Camera3D/rifle_prototype/AudioStreamPlayer"
@onready var gun_barrel = $"Head/Camera3D/rifle_prototype/RayCast3D"
var bullet = load("res://Scenes/Items/bullet.tscn")
var instance

var input_dir = Vector2(0, 0)
var speed = 0.0
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003
const SENSITIVITY_JOYSTICK = 0.06

var is_in_car = false

# Variables pour stocker les valeurs des axes pour les mouvements de camÃ©ra avec manette
var axis_x = 0.0
var axis_y = 0.0

#bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CAHNGE = 1.5

var isAlive = true
var isAiming = false
var isInDialogue = false
var GODMOD = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if !is_multiplayer_authority(): return

	print(multiplayer.get_unique_id())
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	pause_menu.hide()
	health_bar.init_health(100)
	deathLabel.visible = false
	deathLabel.hide()

func _unhandled_input(event):
	if !is_multiplayer_authority(): return  # Added game_paused check
	
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	if event is InputEventJoypadMotion:
		if event.axis == 2:  # Axe horizontal
			axis_x = event.axis_value
		elif event.axis == 3:  # Axe vertical
			axis_y = event.axis_value
	
	input_dir = Input.get_vector("left", "right", "up", "down")
	
	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle Speed
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	
	if Input.is_action_just_pressed("shoot") and animation_player.current_animation != "shoot" and not is_in_car:
		play_shoot_effects.rpc()
	
	if Input.is_action_just_pressed("use"):
		var actionnables = actionable_finder.get_overlapping_areas()
		if actionnables.size() > 0:
			actionnables[0].action()
			pass

	if Input.is_action_just_pressed("pause"):
		pauseMenu()
	
	if Input.is_action_just_pressed("teleport"):
			global_transform.origin = Vector3(0, 10, 0)
	if Input.is_action_just_pressed("god"):
		GODMOD = !GODMOD

func _physics_process(delta):
	if !is_multiplayer_authority(): return
	if GlobalVariables.isInDialogue == false and !paused:
		do_physics_process(delta)

func do_physics_process(delta):
	if axis_x > 0.1 or axis_x < -0.1 or axis_y > 0.1 or axis_y < -0.1:
		head.rotate_y(-axis_x * SENSITIVITY_JOYSTICK)
		camera.rotate_x(-axis_y * SENSITIVITY_JOYSTICK)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	# Add the gravity.
	if not is_on_floor() and GODMOD == false:
		velocity.y -= gravity * delta

	if GODMOD:
		speed = 100
		velocity.y
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CAHNGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	if !Input.is_action_pressed("aim") && isAiming == true:
		if !gun_animation.is_playing():
			isAiming = false
			gun_animation.play_backwards("Aim")

	if animation_player.current_animation == "shoot":
		pass
	else:
		animation_player.stop()

	# Aiming
	if Input.is_action_pressed("aim") && isAiming == false:
		if !gun_animation.is_playing():
			isAiming = true
			gun_animation.play("Aim")
	move_and_slide()

@rpc("any_peer", "call_local")
func play_shoot_effects():
	if !gun_animation.is_playing():
		bullet_sound.play()
		instance = bullet.instantiate()
		instance.position = gun_barrel.global_position
		instance.transform.basis = gun_barrel.global_transform.basis
		get_parent().add_child(instance)
		if isAiming:
			gun_animation.play("Aim_n_Shoot")
		else:
			gun_animation.play("Shoot")

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func _on_health_bar_health_depleted():
	print("dead")
	isAlive = false
	deathLabel.visible = true
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_body_part_hit(dam):
	health_bar.health -= dam

func pauseMenu():
	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		pause_menu.hide()
		get_tree().paused = false
	else:
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pause_menu.show()

	paused = !paused
