extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

var interact_zone = false
@onready var multiplayer_synchronizer = $MultiplayerSynchronizer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()
