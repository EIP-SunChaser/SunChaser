extends Control

@onready var input_button_scene = preload("res://Scenes/Menus/input_button.tscn")
@onready var action_list = $MarginContainer/VBoxContainer/ScrollContainer/ActionList

var is_remapping = false
var action_to_remap = null
var remapping_button = null

const AXIS_DEADZONE = 0.5

var input_actions = {
	"up": "Move forward",
	"left": "Move left",
	"down": "Move backward",
	"right": "Move right",
	"jump": "Jump",
	"sprint": "Sprint",
	"crouch": "Crouch",
	"shoot": "Shoot",
	"aim": "Aim",
	"use": "Use",
	"inventory": "Inventory",
	"accelerate": "Accelerate",
	"deccelerate": "Deccelerate",
	"reset_camera": "Reset camera",
	"brake": "Parking brake",
	"radio": "Radio",
	"pause": "Pause",
	"teleport": "teleport",
	"teleport-2": "teleport-2",
	"teleport-3": "teleport-3",
	"god": "God mode",
}

var controller_type = "Unknown"

func _ready():
	create_action_list()
	controller_type = detect_controller_type()

func create_action_list():
	InputMap.load_from_project_settings()
	for item in action_list.get_children():
		item.queue_free()
	
	for action in input_actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")
		
		action_label.text = input_actions[action]
		
		var events = InputMap.action_get_events(action)
		var keyboard_event = events.filter(func(e): return e is InputEventKey or e is InputEventMouseButton)
		var controller_event = events.filter(func(e): return e is InputEventJoypadButton or (e is InputEventJoypadMotion and abs(e.axis_value) > AXIS_DEADZONE))
		
		var keyboard_text = keyboard_event[0].as_text().trim_suffix(" (Physical)") if keyboard_event else ""
		var controller_text = get_controller_button_name(controller_event[0]) if controller_event else ""
		
		input_label.text = format_input_text(keyboard_text, controller_text)
		
		action_list.add_child(button)
		input_label.pressed.connect(on_input_button_pressed.bind(button, action))

func format_input_text(keyboard_text, controller_text):
	if keyboard_text and controller_text:
		return keyboard_text + " / " + controller_text
	elif keyboard_text:
		return keyboard_text
	elif controller_text:
		return controller_text
	else:
		return ""

func on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press key or button..."

func _input(event):
	if is_remapping:
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			controller_type = detect_controller_type()
		
		if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton or (event is InputEventJoypadMotion and abs(event.axis_value) > AXIS_DEADZONE):
			if event is InputEventMouseButton and event.double_click:
				event.double_click = false
			
			var events = InputMap.action_get_events(action_to_remap)
			var keyboard_events = events.filter(func(e): return e is InputEventKey or e is InputEventMouseButton)
			var controller_events = events.filter(func(e): return e is InputEventJoypadButton or e is InputEventJoypadMotion)
			
			if event is InputEventKey or event is InputEventMouseButton:
				keyboard_events = [event]
			else:
				if event is InputEventJoypadMotion:
					# Create a new event with the correct axis and direction
					var new_event = InputEventJoypadMotion.new()
					new_event.axis = event.axis
					new_event.axis_value = 1 if event.axis_value > 0 else -1
					controller_events = [new_event]
				else:
					controller_events = [event]
			
			InputMap.action_erase_events(action_to_remap)
			for e in keyboard_events + controller_events:
				InputMap.action_add_event(action_to_remap, e)
			
			update_action_list(remapping_button, keyboard_events, controller_events)
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			
			accept_event()

func update_action_list(button, keyboard_events, controller_events):
	var input_label = button.find_child("LabelInput")
	
	var keyboard_text = keyboard_events[0].as_text().trim_suffix(" (Physical)") if keyboard_events else ""
	var controller_text = get_controller_button_name(controller_events[0]) if controller_events else ""
	
	input_label.text = format_input_text(keyboard_text, controller_text)

func get_controller_button_name(event):
	if event is InputEventJoypadButton:
		return get_button_name(event.button_index)
	elif event is InputEventJoypadMotion:
		return get_axis_name(event.axis, event.axis_value)
	return ""

##### TO REPLACE WITH UNIVERSAL ICON #####
 
func get_axis_name(axis, axis_value):
	var direction = "+" if axis_value > 0 else "-"
	match axis:
		JOY_AXIS_LEFT_X: return "Left Stick " + ("Right" if direction == "+" else "Left")
		JOY_AXIS_LEFT_Y: return "Left Stick " + ("Down" if direction == "+" else "Up")
		JOY_AXIS_RIGHT_X: return "Right Stick " + ("Right" if direction == "+" else "Left")
		JOY_AXIS_RIGHT_Y: return "Right Stick " + ("Down" if direction == "+" else "Up")
		JOY_AXIS_TRIGGER_LEFT: return "LT"
		JOY_AXIS_TRIGGER_RIGHT: return "RT"
		_: return "Axis " + str(axis) + direction

func get_button_name(button_index):
	match controller_type:
		"Xbox":
			match button_index:
				JOY_BUTTON_A: return "A"
				JOY_BUTTON_B: return "B"
				JOY_BUTTON_X: return "X"
				JOY_BUTTON_Y: return "Y"
				JOY_BUTTON_LEFT_SHOULDER: return "LB"
				JOY_BUTTON_RIGHT_SHOULDER: return "RB"
				JOY_BUTTON_LEFT_STICK: return "L Stick"
				JOY_BUTTON_RIGHT_STICK: return "R Stick"
				JOY_BUTTON_START: return "Start"
				JOY_BUTTON_BACK: return "Back"
				_: return "Button " + str(button_index)
		"PlayStation":
			match button_index:
				JOY_BUTTON_A: return "Cross"
				JOY_BUTTON_B: return "Circle"
				JOY_BUTTON_X: return "Square"
				JOY_BUTTON_Y: return "Triangle"
				JOY_BUTTON_LEFT_SHOULDER: return "L1"
				JOY_BUTTON_RIGHT_SHOULDER: return "R1"
				JOY_BUTTON_LEFT_STICK: return "L3"
				JOY_BUTTON_RIGHT_STICK: return "R3"
				JOY_BUTTON_START: return "Options"
				JOY_BUTTON_BACK: return "Share"
				_: return "Button " + str(button_index)
		"Nintendo":
			match button_index:
				JOY_BUTTON_A: return "B"
				JOY_BUTTON_B: return "A"
				JOY_BUTTON_X: return "Y"
				JOY_BUTTON_Y: return "X"
				JOY_BUTTON_LEFT_SHOULDER: return "L"
				JOY_BUTTON_RIGHT_SHOULDER: return "R"
				JOY_BUTTON_LEFT_STICK: return "LS"
				JOY_BUTTON_RIGHT_STICK: return "RS"
				JOY_BUTTON_START: return "+"
				JOY_BUTTON_BACK: return "-"
				_: return "Button " + str(button_index)
		_:
			match button_index:
				JOY_BUTTON_A: return "A"
				JOY_BUTTON_B: return "B"
				JOY_BUTTON_X: return "X"
				JOY_BUTTON_Y: return "Y"
				JOY_BUTTON_LEFT_SHOULDER: return "L Shoulder"
				JOY_BUTTON_RIGHT_SHOULDER: return "R Shoulder"
				JOY_BUTTON_LEFT_STICK: return "L Stick"
				JOY_BUTTON_RIGHT_STICK: return "R Stick"
				JOY_BUTTON_START: return "Start"
				JOY_BUTTON_BACK: return "Back"
				_: return "Button " + str(button_index)

func detect_controller_type():
	var joy_name = Input.get_joy_name(0).to_lower()
	if "xbox" in joy_name:
		return "Xbox"
	elif "playstation" in joy_name or "ps5" in joy_name or "ps4" in joy_name or "ps3" in joy_name:
		return "PlayStation"
	elif "nintendo" in joy_name or "switch" in joy_name:
		return "Nintendo"
	else:
		return "Unknown"
