extends ProgressBar

var health = 0 : set = _set_health

signal health_depleted

func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	
	if health <= 0:
		health_depleted.emit()
	
	health = new_health

func init_health(_health):
	health = _health
	max_value = health
	value = health
