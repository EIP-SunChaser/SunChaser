extends Control

@onready var inv: Inv = preload("res://Scenes/Menus/player_inv.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var is_open = false


func _ready():
	inv.update.connect(update_slots)
	update_slots()
	close()


func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])


func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		if is_open:
			close()
		else:
			open()


func open():
	visible = true
	is_open = true
	GlobalVariables.isInInventory = true


func close():
	visible = false
	is_open = false
	GlobalVariables.isInInventory = false
