extends Label

var using_keyboard = true

func _ready():
	update_text()

func _input(event):
	if event is InputEventKey:
		using_keyboard = true
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		using_keyboard = false
	update_text()

func update_text():
	if using_keyboard:
		text = "Press F"
	else:
		text = "Press X"
