class_name Interactable
extends StaticBody3D

@export var prompt_message = "Interact"
@export var prompt_action = "interact"

func get_prompt():
	var events = InputMap.action_get_events("use")
	for event in events:
		if event is InputEventKey:
			var key_name = OS.get_keycode_string(event.physical_keycode)
			return prompt_message + "\n[" + key_name + "]"
	return prompt_message + "\n[ no key assigned ]"
