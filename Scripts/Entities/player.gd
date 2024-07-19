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
@onready var speed_label = $SpeedLabel

@onready var pause_menu = $pause_menu
@onready var inventory = $Inventory

#Bullets
@onready var gun_animation = $"Head/Camera3D/rifle_prototype/AnimationPlayer"
@onready var gun_barrel = $"Head/Camera3D/rifle_prototype/RayCast3D"

var bullet = load("res://Scenes/Items/bullet.tscn")
var instance

var input_dir = Vector2(0, 0)
var speed = 0.0
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const CROUCH_SPEED = 2.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003
var SENSITIVITY_JOYSTICK = 0.06

var is_in_car = false
@export var is_crouching = false
@onready var body_collision = $BodyCollision
@onready var body_mesh = $BodyCollision/BodyMesh
@onready var head_cast = $Head/HeadCast
var animation_paused = false
var uncrouch_buffer = false

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
var god_mode_speed = 100.0

var gravity = 9.8

var respawn_point = Vector3(0, 10, 0)

var sprint_toggled = false

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if !is_multiplayer_authority(): return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	pause_menu.hide()
	health_bar.init_health(100)
	deathLabel.visible = false
	deathLabel.hide()
	head_cast.add_exception(self)

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
	
	if GODMOD and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			god_mode_speed *= 1.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			god_mode_speed *= 0.9
		god_mode_speed = clamp(god_mode_speed, 1.0, 1000.0)
	
	input_dir = Input.get_vector("left", "right", "up", "down")
	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("use"):
		var actionnables = actionable_finder.get_overlapping_areas()
		if actionnables.size() > 0 && actionnables[0].has_method("action"):
			actionnables[0].action()

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

	if Input.is_action_pressed ("god"):
		GODMOD = !GODMOD

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
	
	if not is_on_floor() and GODMOD == false:
		velocity.y -= gravity * delta

	if GODMOD:
		set_collision_mask_value(1, false)
		set_collision_layer_value(1, false)
		velocity = Vector3.ZERO
		
		var camera_basis = camera.get_global_transform().basis
		var move = Vector3.ZERO
		
		move += Input.get_axis("down", "up") * -camera_basis.z
		move += Input.get_axis("left", "right") * camera_basis.x
		move += Input.get_axis("crouch", "jump") * Vector3.UP
		move += Input.get_axis("crouch", "sprint") * Vector3.UP
		
		global_transform.origin += move.normalized() * god_mode_speed * delta
	else:
		set_collision_mask_value(1, true)
		set_collision_layer_value(1, true)

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

	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CAHNGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	if Input.is_action_just_pressed("crouch"):
		crouch.rpc()

	if Input.is_action_pressed("shoot") and not is_in_car:
		play_shoot_effects.rpc()

	if Input.is_action_pressed("aim"):
		SENSITIVITY_JOYSTICK = 0.01
		if not isAiming:
			isAiming = true
			gun_animation.play("aim")
	else:
		SENSITIVITY_JOYSTICK = 0.06
		if isAiming:
			isAiming = false
			gun_animation.play_backwards("aim")

	if Input.is_action_pressed("sprint") or sprint_toggled:
		speed = SPRINT_SPEED if not is_crouching else SPRINT_SPEED / CROUCH_SPEED
	else:
		speed = WALK_SPEED if not is_crouching else WALK_SPEED / CROUCH_SPEED
	
	check_head_collision.rpc()
	move_and_slide()

func _process(_delta):
	if GODMOD:
		speed_label.text = "God Mode Speed: " + str(int(god_mode_speed))
		speed_label.show()
	else:
		speed_label.hide()

@rpc("any_peer", "call_local")
func crouch():
	if not is_crouching:
		animation_player.play("crouch")
		is_crouching = true
	else:
		uncrouch_buffer = true

@rpc("any_peer", "call_local")
func check_head_collision():
	if uncrouch_buffer and not head_cast.is_colliding():
		animation_player.play_backwards("crouch")
		is_crouching = false
		uncrouch_buffer = false

@rpc("any_peer", "call_local")
func play_shoot_effects():
	if not gun_animation.is_playing():
		instance = bullet.instantiate()
		instance.position = gun_barrel.global_position
		instance.transform.basis = gun_barrel.global_transform.basis
		get_parent().add_child(instance)
		instance.get_node("AudioStreamPlayer3D").play()
		if isAiming:
			gun_animation.play("aim_n_shoot")
		else:
			gun_animation.play("shoot")

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
	else:
		GlobalVariables.isInPause = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pause_menu.show()

func inventoryMenu():
	if GlobalVariables.isInInventory == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		inventory.hide()
		GlobalVariables.isInInventory = false
	else:
		GlobalVariables.isInInventory = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		inventory.show()

func respawn():
	global_transform.origin = respawn_point
	health_bar.init_health(100)
	isAlive = true
	deathLabel.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func set_respawn_point(new_point: Vector3):
	respawn_point = new_point
