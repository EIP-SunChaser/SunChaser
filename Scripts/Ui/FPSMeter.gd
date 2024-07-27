extends Control

var max_points = 100
var points = []
var chart_size = Vector2(200, 75)
var update_interval = 0.5
var time_since_last_update = 0
var highest_fps = 0
var lowest_fps = 0
var total_fps = 0
var frame_count = 0
var fps_history = []
var low_1_percent = 0

@onready var label: Label = $CanvasLayer/Label

func _ready():
	for i in range(max_points):
		points.append(Vector2(i, 0))
	
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP

func _process(delta):
	time_since_last_update += delta

	if time_since_last_update >= update_interval:
		var fps = Engine.get_frames_per_second()

		highest_fps = max(highest_fps, fps)
		lowest_fps = min(lowest_fps, fps)
		
		total_fps += fps
		frame_count += 1
		var avg_fps = total_fps / frame_count

		fps_history.append(fps)
		if fps_history.size() > 100:
			fps_history.pop_front()

		var sorted_history = fps_history.duplicate()
		sorted_history.sort()
		var low_1_percent_index = max(0, ceil(sorted_history.size() * 0.01) - 1)
		low_1_percent = sorted_history[low_1_percent_index]

		label.text = "FPS: " + str(fps)
		label.text += "\nAvg FPS: " + str(round(avg_fps))
		label.text += "\n1% Low: " + str(round(low_1_percent))

		var viewport_size = get_viewport_rect().size
		label.position = Vector2(viewport_size.x - label.size.x - chart_size.x - 20, 10)

		for i in range(max_points - 1):
			points[i] = points[i + 1]

		points[max_points - 1] = Vector2(max_points - 1, fps)

		time_since_last_update = 0

		queue_redraw()

func _draw():
	var viewport_size = get_viewport_rect().size
	var chart_position = Vector2(viewport_size.x - chart_size.x - 10, 10)
	draw_rect(Rect2(chart_position, chart_size), Color(0.1, 0.1, 0.1))

	var current_min_fps = INF
	var current_max_fps = 0
	for point in points:
		if point.y > 0:
			current_min_fps = min(current_min_fps, point.y)
			current_max_fps = max(current_max_fps, point.y)

	for i in range(5):
		var y = chart_position.y + chart_size.y - (i * chart_size.y / 4)
		draw_line(Vector2(chart_position.x, y), Vector2(chart_position.x + chart_size.x, y), Color(0.3, 0.3, 0.3))

	for i in range(10):
		var x = chart_position.x + (i * chart_size.x / 9)
		draw_line(Vector2(x, chart_position.y), Vector2(x, chart_position.y + chart_size.y), Color(0.3, 0.3, 0.3))

	for i in range(4):
		var fps_value = current_min_fps + (current_max_fps - current_min_fps) * i / 4
		var y = chart_position.y + chart_size.y - (i * chart_size.y / 4)	
		draw_string(get_theme_default_font(), Vector2(chart_position.x, y), str(round(fps_value)), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.7, 0.7, 0.7))

	if current_max_fps > current_min_fps:
		for i in range(1, max_points):
			var start = Vector2(
				chart_position.x + chart_size.x * (i - 1) / max_points,
				chart_position.y + chart_size.y - ((points[i - 1].y - current_min_fps) / (current_max_fps - current_min_fps) * chart_size.y)
			)
			var end = Vector2(
				chart_position.x + chart_size.x * i / max_points,
				chart_position.y + chart_size.y - ((points[i].y - current_min_fps) / (current_max_fps - current_min_fps) * chart_size.y)
			)
			if start.x >= chart_position.x and start.x <= chart_position.x + chart_size.x and start.y >= chart_position.y and start.y <= chart_position.y + chart_size.y and \
			   end.x >= chart_position.x and end.x <= chart_position.x + chart_size.x and end.y >= chart_position.y and end.y <= chart_position.y + chart_size.y:
				draw_line(start, end, Color(0, 1, 0), 2)
