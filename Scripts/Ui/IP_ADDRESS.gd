extends Label3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var addresses = []
	for ip in IP.get_local_addresses():
		if ip.begins_with("10.") or ip.begins_with("172.16.") or ip.begins_with("192.168."):
			addresses.push_back(ip)
	text = addresses[-1]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
