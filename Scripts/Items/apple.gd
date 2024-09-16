extends Interactable

@export var item: InvItem
var player = null

func _on_interacted(body):
	$AudioStreamPlayer3D.play()
	player = body
	player.collect(item)
	#queue_free()
