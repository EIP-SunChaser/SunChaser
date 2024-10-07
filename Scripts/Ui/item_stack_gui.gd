extends Panel

class_name Item_stack_gui

@onready var item_sprite: Sprite2D =  $item
@onready var amount_label: Label = $Label

var inventory_slot: Inventory_slot

func update():
	if !inventory_slot || !inventory_slot.item: return
	
	item_sprite.visible = true
	item_sprite.texture = inventory_slot.item.texture
	
	if inventory_slot.amount > 1:
		amount_label.visible = true
		amount_label.text = str(inventory_slot.amount)
	else:
		amount_label.visible = false
