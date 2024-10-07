extends Area3D

@export var item_res: Inventory_item

func collect(inventory: Inventory):
	if Input.is_action_just_pressed("use"):
		inventory.insert(item_res)
		#queue_free()
