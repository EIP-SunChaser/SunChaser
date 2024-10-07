extends Label

var tips = [
	"Remember to brake early when approaching turns.",
	"Always check your mirrors before changing lanes.",
	"Maintain a safe following distance from the car in front of you.",
	"Use your turn signals when changing directions.",
	"Adjust your speed according to weather conditions.",
	"Keep your tires properly inflated for better fuel efficiency.",
	"Don't text and drive - it's dangerous and often illegal.",
	"Regularly check and change your oil to keep your engine healthy.",
	"Always wear your seatbelt, even for short trips.",
	"Be extra cautious in construction zones."
]

func _ready() -> void:
	select_random_tip()

func _process(delta: float) -> void:
	pass

func select_random_tip() -> void:
	if tips.size() > 0:
		var random_index = randi() % tips.size()
		text = tips[random_index]
	else:
		text = "No tips available."
