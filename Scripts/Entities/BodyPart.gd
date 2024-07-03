extends Area3D

@export var damage := 1

signal body_part_hit(dam)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func hit():
	print("Hit")
	emit_signal("body_part_hit", damage)


func _on_body_entered(body):
	pass # Replace with function body.
