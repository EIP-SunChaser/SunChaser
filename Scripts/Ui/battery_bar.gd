@tool
extends ProgressBar

signal battery_depleted

@export var battery = 100.0 : set = set_battery
@export var bar_height = 30
@export var gradient: Gradient
@export var background_color: Color = Color(0, 0, 0, 0)

func _ready():
	if !is_multiplayer_authority():
		self.hide()
	
	if not gradient:
		gradient = Gradient.new()
		gradient.add_point(0.0, Color.RED)
		gradient.add_point(0.5, Color.YELLOW)
		gradient.add_point(1.0, Color.GREEN)
	
	update_appearance()

func update_appearance():
	# Set the size of the ProgressBar
	custom_minimum_size = Vector2(0, bar_height)
	
	# Create a gradient texture
	var gradient_texture = GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.width = 100  # Width doesn't matter much, it will be stretched
	gradient_texture.height = bar_height - 2
	gradient_texture.fill_from = Vector2(0, 0.5)
	gradient_texture.fill_to = Vector2(1, 0.5)
	
	# Create StyleBoxFlat for the background
	var background_style = StyleBoxFlat.new()
	background_style.bg_color = background_color
	
	# Apply styles
	add_theme_stylebox_override("background", background_style)

func set_battery(new_battery):
	var prev_battery = battery
	battery = min(max_value, new_battery)
	value = battery
	if battery <= 0:
		battery_depleted.emit()
	
	battery = new_battery

func init_battery(_battery):
	battery = _battery
	max_value = battery
	value = battery

func _property_changed():
	update_appearance()
