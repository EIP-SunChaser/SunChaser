class_name SafeResourceLoader

static func load(path:String, type_hint:String = "", \
		cache_mode:ResourceLoader.CacheMode = ResourceLoader.CacheMode.CACHE_MODE_REUSE) -> Resource:

	if not path.ends_with(".tres"):
		push_error("Only .tres files are supported.")
		return null	

	if path.begins_with("res://"):
		push_error("Can't load resource from res:// folder.")
		return null

	if not FileAccess.file_exists(path):
		push_error("Cannot load resource '" + path + "' because it does not exist or is not accessible.")
		return null
	
	var file = FileAccess.open(path, FileAccess.READ)
	var file_as_text = file.get_as_text()
	file.close()

	var regex:RegEx = RegEx.new()
	regex.compile("type\\s*=\\s*\"GDScript\"\\s*")	
	
	if regex.search(file_as_text) != null:
		push_error("Resource '" + path + "' contains inline GDScripts.")
		return null

	var extResourceRegex:RegEx = RegEx.new()
	extResourceRegex.compile("\\[\\s*ext_resource\\s*.*?path\\s*=\\s*\"([^\"]*)\".*?\\]")
	var matches:Array = extResourceRegex.search_all(file_as_text)
	for match in matches:
		var resourcePath:String = match.get_string(1)
		if not resourcePath.begins_with("res://"):
			push_error("Resource '" + path + "' contains an ext_resource with a path\n outside 'res://' (path is: '" + resourcePath + "').")
			return null

	return ResourceLoader.load(path, type_hint, cache_mode)
