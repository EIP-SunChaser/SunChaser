extends Control

var using_keyboard = true
var controller_type = "Unknown"
@onready var title_song = $Title_song
var events

func _ready():
	update_text()

func _input(event):
	if event is InputEventKey:
		update_text()

func update_text():
		events = InputMap.action_get_events("radio")
		for event in events:
			if event is InputEventKey:
				var key_name = OS.get_keycode_string(event.physical_keycode)
				title_song.text = "Press " + key_name + " to play"
				return
		title_song.text = "No keyboard input assigned"
