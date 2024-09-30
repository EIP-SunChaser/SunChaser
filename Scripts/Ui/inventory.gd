extends Resource

class_name Inventory

signal updated

@export var slots: Array[Inventory_slot]

func insert(item: Inventory_item):
	var item_slots = slots.filter(func(slot): return slot.item == item)
	if !item_slots.is_empty():
		if item_slots[0].amount >= item_slots[0].item.stack_size:
			var empty_slots = slots.filter(func(slot): return slot.item == null)
			if !empty_slots.is_empty():
				empty_slots[0].item = item
				empty_slots[0].amount = 1
		else:
			item_slots[0].amount += 1
	else:
		var empty_slots = slots.filter(func(slot): return slot.item == null)
		if !empty_slots.is_empty():
			empty_slots[0].item = item
			empty_slots[0].amount = 1
			
	updated.emit()


func remove_item_at_index(index: int):
	slots[index] = Inventory_slot.new()


func insert_slot(index: int, inventory_slot: Inventory_slot):
	var old_index: int = slots.find(inventory_slot)
	remove_item_at_index(old_index)
	
	slots[index] = inventory_slot
