extends RayCast3D

@onready var prompt = $Prompt

# Called when the node enters the scene tree for the first time.
func _ready():
	add_exception(owner)
	
func _physics_process(delta):
	prompt.text = ""
	if is_colliding():
		var detected = get_collider()
	
		if detected is Interactable:
			prompt.text = detected.get_prompt()
			
			if Input.is_action_just_pressed("use"):
				detected.interact(owner)
