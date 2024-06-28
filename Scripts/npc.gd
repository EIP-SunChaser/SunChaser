extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

var health = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()


func _on_body_part_hit(dam):
	health -= dam
	if health <= 0:
		GlobalQuest.entity_kill += 1
		if is_in_group("Bandits"):
			print("Bandit is dead")
		queue_free()
