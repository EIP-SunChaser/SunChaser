extends VBoxContainer

var check_quest = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if check_quest == false:
		if GlobalVariables.quest1:
			var name_label = Label.new()
			name_label.text = "whatever"
			add_child(name_label)
			check_quest = true
