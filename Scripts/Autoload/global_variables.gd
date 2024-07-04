extends Node

#-------------- Player Variables --------------#
var isInDialogue: bool = false

#-------------- Quest --------------#
enum check_quest {NOTHING, GO_CAMP_ONE, GO_CAMP_TWO, KILL_RED_ONE, KILL_RED_TWO, TALK_FORESTIERS_ONE, TALK_FORESTIERS_TWO, GROW_TREE_ONE, GROW_TREE_TWO, END_ONE, END_TWO, FINISH_ONE, FINISH_TWO}
var quest_one = GlobalVariables.check_quest.NOTHING
var entity_kill: int = 0
var grow_tree: int = 0
