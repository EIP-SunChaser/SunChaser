extends Area3D

@onready var inventory_gui = $"../inventory_gui"

func interact_inv(inv_player):
	if Input.is_action_just_pressed("use"):
		if inventory_gui.is_open:
			inventory_gui.close()
			inv_player.close()
			GlobalVariables.isInInventory = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			inventory_gui.open()
			inv_player.open()
			GlobalVariables.isInInventory = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		inventory_gui.update_item_in_hand()
	
	if Input.is_action_just_pressed("inventory"):
		if inventory_gui.is_open:
			inventory_gui.close()
			GlobalVariables.isInInventory = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
