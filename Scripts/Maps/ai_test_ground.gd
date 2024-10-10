extends Node3D


func _on_area_3d_area_exited(area):
	print("Area exited by: ", area)


func _on_area_3d_area_entered(area):
	print("Area entered by: ", area)
