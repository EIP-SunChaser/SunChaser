extends VBoxContainer

@export var quest_one_label: Label
@export var test = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	test = GlobalVariables.quest_one
	match GlobalVariables.quest_one:
		GlobalVariables.check_quest.GO_CAMP_ONE:
			quest_one_label = Label.new()
			quest_one_label.text = "Aller au camps de forestiers"
			add_child(quest_one_label)
			GlobalVariables.quest_one = GlobalVariables.check_quest.GO_CAMP_TWO
		GlobalVariables.check_quest.KILL_RED_ONE:
			quest_one_label.text = "Tuer red: " +  str(GlobalVariables.entity_kill) + "/3"
			GlobalVariables.quest_one = GlobalVariables.check_quest.KILL_RED_TWO
		GlobalVariables.check_quest.TALK_FORESTIERS_ONE:
			quest_one_label.text = "Aller parler aux forestiers"
			GlobalVariables.quest_one = GlobalVariables.check_quest.TALK_FORESTIERS_TWO
		GlobalVariables.check_quest.GROW_TREE_ONE:
			quest_one_label.text = "Faire repousser des arbres: " + str(GlobalVariables.grow_tree) + "/6"
			GlobalVariables.quest_one = GlobalVariables.check_quest.GROW_TREE_TWO
		GlobalVariables.check_quest.END_ONE:
			quest_one_label.text = "Retourner voir Gus, le maire"
			GlobalVariables.quest_one = GlobalVariables.check_quest.END_TWO
		GlobalVariables.check_quest.FINISH_ONE:
			quest_one_label.queue_free()
			GlobalVariables.quest_one = GlobalVariables.check_quest.FINISH_TWO
