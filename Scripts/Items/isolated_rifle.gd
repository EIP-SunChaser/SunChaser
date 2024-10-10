extends Node3D

@onready var gun_animation = $"AnimationPlayer"
@onready var gun_barrel = $"RayCast3D"

var bullet = load("res://Scenes/Items/bullet.tscn")
var instance

func isAnimationEnded() -> bool:
	if gun_animation.is_playing():
		return false
	return true

func spawnNewBullet():
	instance = bullet.instantiate()
	instance.position = gun_barrel.global_position
	instance.transform.basis = gun_barrel.global_transform.basis
	get_tree().root.add_child(instance)
	
func playShootingAnimation():
	gun_animation.play("shoot")

func play_shoot_effects():
	if isAnimationEnded():
		spawnNewBullet()
		#instance.get_node("AudioStreamPlayer3D").play() 			#needs to add 3D sound in the world
		playShootingAnimation()
