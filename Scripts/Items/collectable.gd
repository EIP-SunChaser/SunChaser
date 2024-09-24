extends Area3D

@export var item_res: Inventory_item

func collect(inventory: Inventory):
	inventory.insert(item_res)
	#queue_free()
