extends Node

var modded_wheels = {}
var modded_springs = {}
var processed_files = {}

func _ready():
	load_mods()

func load_mods():
	var mods_dir = "user://mods/"
	var dir = DirAccess.open(mods_dir)
	if not dir:
		DirAccess.make_dir_absolute(mods_dir)
		return

	for file_name in dir.get_files():
		if file_name.get_extension() in ["pck", "zip"]:
			var full_path = mods_dir.path_join(file_name)
			if ProjectSettings.load_resource_pack(full_path):
				check_directory_for_car_parts("res://car_parts", file_name.get_basename())
			else:
				print("Failed to load mod: ", file_name)

func check_directory_for_car_parts(path, mod_name):
	var dir = DirAccess.open(path)
	if not dir:
		print("Could not open directory: ", path)
		return

	for directory in dir.get_directories():
		if directory in ["wheels", "springs"]:
			load_modded_parts(mod_name, directory, path.path_join(directory))

func load_modded_parts(mod_name, part_type, dir_path):
	var dir = DirAccess.open(dir_path)
	if not dir:
		print("An error occurred when trying to access the path: ", dir_path)
		return

	var target_dict = modded_wheels if part_type == "wheels" else modded_springs
	
	for file_name in dir.get_files():
		if file_name.ends_with(".tres.remap"):
			file_name = file_name.trim_suffix(".remap")
		
		if file_name.get_extension() == "tres":
			var full_path = dir_path.path_join(file_name)
			if full_path in processed_files:
				continue

			var part_resource = load(full_path)
			if part_resource:
				if mod_name not in target_dict:
					target_dict[mod_name] = []
				target_dict[mod_name].append(part_resource)
				print("Loaded modded %s: %s from mod: %s" % [part_type, file_name, mod_name])
				processed_files[full_path] = true
