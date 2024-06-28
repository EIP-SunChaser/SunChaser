extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GlobalQuest.quest1:
		get_node("Quest1").text = "Red kill: " + str(GlobalQuest.entity_kill)
	else:
		get_node("Quest1").text = "No quest !"
