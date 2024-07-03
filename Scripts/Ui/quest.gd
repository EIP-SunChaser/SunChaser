extends VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	match GlobalVariables.quest_one:
		GlobalVariables.check_quest.GO_CAMP_ONE:
			var quest_one = Label.new()
			quest_one.text = "Aller au camps de forestiers"
			add_child(quest_one)
			GlobalVariables.quest_one = GlobalVariables.check_quest.GO_CAMP_TWO
		GlobalVariables.check_quest.KILL_RED_ONE:
			var quest_one = Label.new()
			quest_one.text = "Tuer red"
			add_child(quest_one)
			GlobalVariables.quest_one = GlobalVariables.check_quest.KILL_RED_TWO
		GlobalVariables.check_quest.END_ONE:
			var quest_one = Label.new()
			quest_one.text = "Retourner voir Mr le maire"
			add_child(quest_one)
			GlobalVariables.quest_one = GlobalVariables.check_quest.END_TWO
