extends Label

var using_keyboard = true
var controller_type = "Unknown"

func _ready():
	update_text()

func _input(event):
	if event is InputEventKey:
		using_keyboard = true
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		using_keyboard = false
		detect_controller_type()
	update_text()

func detect_controller_type():
	var joy_name = Input.get_joy_name(0).to_lower()
	if "xbox" in joy_name:
		controller_type = "Xbox"
	elif "playstation" in joy_name or "ps5" in joy_name or "ps4" in joy_name or "ps3" in joy_name:
		controller_type = "PlayStation"
	elif "nintendo" in joy_name or "switch" in joy_name:
		controller_type = "Nintendo"
	else:
		controller_type = "Unknown"

func update_text():
	if using_keyboard:
		var events = InputMap.action_get_events("use")
		for event in events:
			if event is InputEventKey:
				var key_name = OS.get_keycode_string(event.physical_keycode)
				text = "Press " + key_name
				return
		text = "No keyboard input assigned"
	else:
		var events = InputMap.action_get_events("use")
		for event in events:
			if event is InputEventJoypadButton:
				text = "Press " + get_button_name(event.button_index)
				return
		text = "No controller button assigned"

func get_button_name(button_index):
	match controller_type:
		"Xbox":
			match button_index:
				JOY_BUTTON_A: return "A"
				JOY_BUTTON_B: return "B"
				JOY_BUTTON_X: return "X"
				JOY_BUTTON_Y: return "Y"
				_: return str(button_index)
		"PlayStation":
			match button_index:
				JOY_BUTTON_A: return "Cross"
				JOY_BUTTON_B: return "Circle"
				JOY_BUTTON_X: return "Square"
				JOY_BUTTON_Y: return "Triangle"
				_: return str(button_index)
		"Nintendo":
			match button_index:
				JOY_BUTTON_A: return "B"
				JOY_BUTTON_B: return "A"
				JOY_BUTTON_X: return "Y"
				JOY_BUTTON_Y: return "X"
				_: return str(button_index)
		_:
			return str(button_index)
