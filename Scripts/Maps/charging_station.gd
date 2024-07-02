extends Node3D

@export var recharge_amount: float = 10.0  # Amount to recharge per second
@export var recharge_interval: float = 0.01  # How often to apply recharge (in seconds)
@export var recharge_delay: float = 1.0  # Delay in seconds before recharging starts

var car_in_area: RigidBody3D = null
var recharge_timer: float = 0.0
var delay_timer: float = 0.0
var is_charging: bool = false

func _ready():
	pass

func _process(delta):
	if car_in_area and car_in_area.has_method("recharge_battery"):
		if not is_charging:
			delay_timer += delta
			if delay_timer >= recharge_delay:
				is_charging = true
		else:
			recharge_timer += delta
			if recharge_timer >= recharge_interval:
				var amount_to_recharge = recharge_amount * recharge_interval
				car_in_area.recharge_battery(amount_to_recharge)
				recharge_timer = 0.0

func _on_area_3d_area_entered(area):
	var potential_car = area.get_parent()
	if potential_car is RigidBody3D and potential_car.has_method("recharge_battery"):
		car_in_area = potential_car
		delay_timer = 0.0
		is_charging = false

func _on_area_3d_area_exited(area):
	var potential_car = area.get_parent()
	if potential_car == car_in_area:
		car_in_area = null
		is_charging = false
