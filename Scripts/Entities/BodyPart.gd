extends Area3D

@export var damage := 1

signal body_part_hit(dam: int)

func hit():
	body_part_hit.emit(damage)
