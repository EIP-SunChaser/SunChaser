extends Node3D

@onready var hat_npc_2 = $Hat_npc2
@onready var forestier = $Forestier
@onready var forestier_2 = $Forestier2
@onready var forestier_3 = $Forestier3


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GlobalVariables.quest_one >= 5:
		forestier.show()
		forestier_2.show()
		forestier_3.show()
	else:
		forestier.hide()
		forestier_2.hide()
		forestier_3.hide()

	if GlobalVariables.quest_one >= 9:
		hat_npc_2.show()
	else:
		hat_npc_2.hide()
	pass
