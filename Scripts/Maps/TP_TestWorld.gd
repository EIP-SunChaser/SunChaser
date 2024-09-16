extends Area3D

var current_scene = null

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
	connect("body_entered", Callable(self, "_on_area_entered"))
#
#func change_scene(path: String):
	##current_scene.queue_free()
	##var new_scene = ResourceLoader.load(path)
	##current_scene = new_scene.instantiate()
	##get_tree().get_root().add_child(current_scene)
	##get_tree().set_current_scene(current_scene)
#
	#


func _on_area_entered(body):
	var players = get_tree().get_nodes_in_group("Player")
	print(body.name)
	print(multiplayer.get_unique_id())

	if str(multiplayer.get_unique_id()) == body.name :
		if current_scene.name == "World":
			get_tree().change_scene_to_file('res://Scenes/Maps/test_world.tscn')
		elif current_scene.name == "TestWorld":
			get_tree().change_scene_to_file('res://Scenes/Maps/world.tscn')
			
		#elif p.name != "World":
			#p.visible = false
			#p.set_physics_process(false)

