extends Control

var is_open = false

@export var inv: Inventory

@onready var inventory: Inventory = inv
@onready var Item_stack_gui_class = preload("res://Scenes/Ui/item_stack_gui.tscn")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

func _ready():
	connect_slots()
	inventory.updated.connect(update)
	update()
	close()
	GlobalVariables.isInInventory = false


func connect_slots():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		
		var callable = Callable(on_slot_clicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)
		


func update():
	for i in range(min(inventory.slots.size(), slots.size())):
		var inventory_slot: Inventory_slot = inventory.slots[i]
		
		if !inventory_slot.item: continue
		
		var item_stack_gui: Item_stack_gui = slots[i].item_stack_gui
		if !item_stack_gui:
			item_stack_gui = Item_stack_gui_class.instantiate()
			slots[i].insert(item_stack_gui)
			
		item_stack_gui.inventory_slot = inventory_slot
		item_stack_gui.update()


func open():
	visible = true
	is_open = true


func close():
	visible = false
	is_open = false


func on_slot_clicked(slot):
	if slot.is_empty():
		if !GlobalVariables.item_in_hand: return
		
		insert_item_in_slot(slot)
		return
	
	if !GlobalVariables.item_in_hand:
		take_item_from_slot(slot)
		return
	
	if slot.item_stack_gui.inventory_slot.item.name == GlobalVariables.item_in_hand.inventory_slot.item.name:
		stack_items(slot)
		return
	
	swap_items(slot)


func take_item_from_slot(slot):
	GlobalVariables.item_in_hand = slot.take_item()
	add_child(GlobalVariables.item_in_hand)
	update_item_in_hand()


func insert_item_in_slot(slot):
	var item = GlobalVariables.item_in_hand
	
	remove_child(GlobalVariables.item_in_hand)
	GlobalVariables.item_in_hand = null
	slot.insert(item)


func swap_items(slot):
	var temp_item = slot.take_item()
	
	insert_item_in_slot(slot)
	
	GlobalVariables.item_in_hand = temp_item
	add_child(GlobalVariables.item_in_hand)
	update_item_in_hand()


func stack_items(slot):
	var slot_item: Item_stack_gui = slot.item_stack_gui
	var max_amount = slot_item.inventory_slot.item.stack_size
	var total_amount = slot_item.inventory_slot.amount + GlobalVariables.item_in_hand.inventory_slot.amount
	
	if slot_item.inventory_slot.amount == max_amount:
		swap_items(slot)
		return
	
	if total_amount <= max_amount:
		slot_item.inventory_slot.amount = total_amount
		remove_child(GlobalVariables.item_in_hand)
		GlobalVariables.item_in_hand = null
	else:
		slot_item.inventory_slot.amount = max_amount
		GlobalVariables.item_in_hand.inventory_slot.amount = total_amount - max_amount
	
	slot_item.update()
	if GlobalVariables.item_in_hand: GlobalVariables.item_in_hand.update()


func update_item_in_hand():
	if !GlobalVariables.item_in_hand: return
	GlobalVariables.item_in_hand.global_position = get_global_mouse_position() - GlobalVariables.item_in_hand.size / 2
