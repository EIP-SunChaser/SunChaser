extends Node

var camera3D: Camera3D
@onready var tween: Tween
var transitioning: bool = false

func _ready() -> void:
	if camera3D:
		camera3D.current = false

func switch_camera(from, to) -> void:
	from.current = false
	to.current = true

func transition_camera3D(from: Camera3D, to: Camera3D, duration: float = 1.0) -> void:
	if transitioning:
		tween.kill()
	
	if not camera3D:
		camera3D = Camera3D.new()
		add_child(camera3D)

	camera3D.fov = from.fov
	camera3D.cull_mask = from.cull_mask
	camera3D.global_transform = from.global_transform
	camera3D.current = true
	
	transitioning = true
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera3D, "global_transform", to.global_transform, duration).from(camera3D.global_transform)
	tween.tween_property(camera3D, "fov", to.fov, duration).from(camera3D.fov)
	
	await tween.finished
	
	to.current = true
	transitioning = false
