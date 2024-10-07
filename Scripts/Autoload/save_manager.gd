extends Node

const SAVE_DIR = "user://saves"
const SAVE_FILE = SAVE_DIR + "/save.tres"
var save_timer = null
const SAVE_INTERVAL = 60
var save_data: SaveData

func _ready():
	save_data = SaveData.new()
	save_timer = Timer.new()
	save_timer.timeout.connect(_on_save_timer_timeout)
	save_timer.set_wait_time(SAVE_INTERVAL)
	save_timer.set_one_shot(false)
	add_child(save_timer)
	save_timer.start()

func _on_save_timer_timeout():
	save_game()

func save_game():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(SAVE_DIR):
		dir.make_dir(SAVE_DIR)
	
	var persist_objects = get_tree().get_nodes_in_group("Persist")
	
	for obj in persist_objects:
		if obj.has_method("save_data"):
			obj.save_data(save_data)
	
	var error = ResourceSaver.save(save_data, SAVE_FILE)
	if error != OK:
		print("An error occurred while saving the game to %s." % SAVE_FILE)

func load_game():
	await get_tree().create_timer(0.01).timeout
	if not FileAccess.file_exists(SAVE_FILE):
		return
	
	var loaded_save_data = SafeResourceLoader.load(SAVE_FILE) as SaveData
	if not loaded_save_data:
		return
	
	save_data = loaded_save_data
	
	var persist_objects = get_tree().get_nodes_in_group("Persist")
	
	for obj in persist_objects:
		if obj.has_method("load_data"):
			obj.load_data(save_data)
