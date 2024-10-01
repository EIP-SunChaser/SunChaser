extends Button

@onready var background_sprite: Sprite2D = $background
@onready var container: CenterContainer = $CenterContainer

@onready var inventory = preload("res://Ressources/player_inventory.tres")

var item_stack_gui: Item_stack_gui
var index: int

func insert(isg: Item_stack_gui):
	item_stack_gui = isg
	container.add_child(item_stack_gui)
	
	if !item_stack_gui.inventory_slot || inventory.slots[index] == item_stack_gui.inventory_slot:
		return
	
	inventory.insert_slot(index, item_stack_gui.inventory_slot)


func take_item():
	var item = item_stack_gui
	
	container.remove_child(item_stack_gui)
	item_stack_gui = null
	return item

func is_empty():
	return !item_stack_gui
