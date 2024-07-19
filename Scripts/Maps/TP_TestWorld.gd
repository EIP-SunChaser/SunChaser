extends Area3D

var current_scene = null

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
	connect("body_entered", Callable(self, "_on_area_entered"))

func change_scene(path: String):
	current_scene.queue_free()
	var new_scene = ResourceLoader.load(path)
	current_scene = new_scene.instantiate()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)

func _on_area_entered(_body):
	if current_scene.name == "World":
		change_scene('res://Scenes/Maps/test_world.tscn')
	elif current_scene.name == "TestWorld":
		change_scene('res://Scenes/Maps/world.tscn')
