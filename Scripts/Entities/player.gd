extends CharacterBody3D

@onready var camera = $Head/Camera3D
@onready var head = $Head
@onready var animation_player = $AnimationPlayer
@onready var pseudo = $Pseudo
@onready var actionable_finder: Area3D = $Area3D
@onready var press_e_ui = $Head/Camera3D/Press_e_ui
@onready var deathLabel = $"Head/Camera3D/DeathLabel"
@onready var health_bar = $Head/Camera3D/HealthBar
@onready var quest_ui = $Head/Camera3D/Quest_ui

@onready var pause_menu = $pause_menu
@onready var inventory = $Inventory

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
const CROUCH_SPEED = 2.5
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003
var SENSITIVITY_JOYSTICK = 0.06

var is_in_car = false
var is_crouching = false
@onready var body_collision = $BodyCollision

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

var standing_height = 1.0
var crouching_height = 0.5

var respawn_point = Vector3(0, 10, 0)

var sprint_toggled = false

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
	
	standing_height = body_collision.scale.y
	crouching_height = standing_height * 0.8

func _unhandled_input(event):
	if !is_multiplayer_authority(): return
	
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
	
	if Input.is_action_pressed("shoot") and animation_player.current_animation != "shoot" and not is_in_car:
		play_shoot_effects.rpc()
	
	if Input.is_action_just_pressed("use"):
		var actionnables = actionable_finder.get_overlapping_areas()
		if actionnables.size() > 0 && actionnables[0].has_method("action"):
			actionnables[0].action()
			pass

	if Input.is_action_just_pressed("pause"):
		pauseMenu()
	
	if Input.is_action_just_pressed("inventory"):
		inventoryMenu()
	
	if Input.is_action_just_pressed("teleport"):
			global_transform.origin = Vector3(0, 10, 0)
			
	if Input.is_action_just_pressed("teleport-2"):
			global_transform.origin = Vector3(-1220, 20, -15)
			
	if Input.is_action_just_pressed("teleport-3"):
			global_transform.origin = Vector3(-230, 20, -10)

	if Input.is_action_just_pressed("god"):
		GODMOD = !GODMOD

	if Input.is_action_just_pressed("crouch"):
		crouch()
		
	if event.is_action_pressed("sprint") and event is InputEventJoypadButton:
		sprint_toggled = !sprint_toggled
	elif event.is_action_released("sprint") and event is InputEventKey:
		sprint_toggled = false

func _physics_process(delta):
	if !is_multiplayer_authority(): return
	if !isAlive: return
	
	if GlobalVariables.isInDialogue == true || GlobalVariables.isInPause == true || GlobalVariables.isInInventory == true:
		health_bar.hide()
		quest_ui.hide()
		press_e_ui.hide()
	else:
		health_bar.show()
		quest_ui.show()

	if GlobalVariables.isInDialogue == false and !GlobalVariables.isInPause and GlobalVariables.isInInventory == false:
		if actionable_finder.get_overlapping_areas():
			var action_func = actionable_finder.get_overlapping_areas()
			if action_func.size() > 0 && action_func[0].has_method("action"):
				press_e_ui.show()
		else:
			press_e_ui.hide()
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
		SENSITIVITY_JOYSTICK = 0.06
		if !gun_animation.is_playing():
			isAiming = false
			gun_animation.play_backwards("Aim")

	if animation_player.current_animation == "shoot":
		pass
	else:
		animation_player.stop()

	# Aiming
	if Input.is_action_pressed("aim") && isAiming == false:
		SENSITIVITY_JOYSTICK = 0.01
		if !gun_animation.is_playing():
			isAiming = true
			gun_animation.play("Aim")

	if is_crouching:
		speed = CROUCH_SPEED
	elif Input.is_action_pressed("sprint") or sprint_toggled:
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	move_and_slide()

func crouch():
	if is_on_floor() and not is_in_car:
		if not is_crouching:
			is_crouching = true
			scale_character(crouching_height)
		else:
			is_crouching = false
			scale_character(standing_height)

func scale_character(target_height):
	var scale_factor = target_height / body_collision.scale.y
	body_collision.scale.y = target_height
	
	# Adjust the camera position
	var camera_offset = camera.position.y - head.position.y
	head.position.y *= scale_factor
	camera.position.y = head.position.y + camera_offset

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
	isAlive = false
	deathLabel.visible = true
	await get_tree().create_timer(3.0).timeout
	respawn()

func _on_body_part_hit(dam):
	health_bar.health -= dam

func pauseMenu():
	if GlobalVariables.isInPause == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		pause_menu.hide()
		GlobalVariables.isInPause = false
		pass
	else:
		GlobalVariables.isInPause = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pause_menu.show()
		pass

func inventoryMenu():
	if GlobalVariables.isInInventory == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		inventory.hide()
		GlobalVariables.isInInventory = false
		pass
	else:
		GlobalVariables.isInInventory = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		inventory.show()
		pass

func respawn():
	global_transform.origin = respawn_point
	health_bar.init_health(100)
	isAlive = true
	deathLabel.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func set_respawn_point(new_point: Vector3):
	respawn_point = new_point
