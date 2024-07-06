extends Control

@onready var input_button_scene = preload("res://Scenes/Menus/input_button.tscn")
@onready var action_list = $MarginContainer/VBoxContainer/ScrollContainer/ActionList

var is_remapping = false
var action_to_remap = null
var remapping_button = null

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
	"pause": "Pause",
	"teleport": "teleport",
	"teleport-2": "teleport-2",
	"teleport-3": "teleport-3",
	"god": "God mode",
}

# Called when the node enters the scene tree for the first time.
func _ready():
	create_action_list()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
		
		action_list.add_child(button)
		button.pressed.connect(on_input_button_pressed.bind(button, action))

func on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press key to bind..."

func _input(event):
	if is_remapping:
		if (event is InputEventKey || (event is InputEventMouseButton && event.pressed)):
			if event is InputEventMouseButton && event.double_click:
				event.double_click = false
			
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			update_action_list(remapping_button, event)
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			
			accept_event()
			
func update_action_list(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")


func _on_reset_button_pressed():
	create_action_list()
