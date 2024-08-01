extends Node3D

@onready var animation = $"AnimationPlayer"

func _process(delta):
	if not animation.is_playing():
		animation.play("Test")
		print("Test")
	print("pass")

