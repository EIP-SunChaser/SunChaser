extends Control

var max_points = 100
var points = []
var chart_size = Vector2(200, 75)
var update_interval = 0.1
var time_since_last_update = 0
var highest_fps = 0
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

	for i in range(5):
		var y = chart_position.y + chart_size.y - (i * chart_size.y / 4)
		draw_line(Vector2(chart_position.x, y), Vector2(chart_position.x + chart_size.x, y), Color(0.3, 0.3, 0.3))

	for i in range(10):
		var x = chart_position.x + (i * chart_size.x / 9)
		draw_line(Vector2(x, chart_position.y), Vector2(x, chart_position.y + chart_size.y), Color(0.3, 0.3, 0.3))

	if highest_fps > 0:
		for i in range(1, max_points):
			var start = Vector2(
				chart_position.x + chart_size.x * (i - 1) / max_points,
				chart_position.y + chart_size.y - (points[i - 1].y / highest_fps * chart_size.y)
			)
			var end = Vector2(
				chart_position.x + chart_size.x * i / max_points,
				chart_position.y + chart_size.y - (points[i].y / highest_fps * chart_size.y)
			)
			draw_line(start, end, Color(0, 1, 0), 2)

	if frame_count > 0:
		var avg_fps = total_fps / frame_count
		var avg_y = chart_position.y + chart_size.y - (avg_fps / highest_fps * chart_size.y)
		draw_line(Vector2(chart_position.x, avg_y), Vector2(chart_position.x + chart_size.x, avg_y), Color(1, 0, 0), 1)

	if low_1_percent > 0:
		var low_y = chart_position.y + chart_size.y - (low_1_percent / highest_fps * chart_size.y)
		draw_line(Vector2(chart_position.x, low_y), Vector2(chart_position.x + chart_size.x, low_y), Color(1, 1, 0), 1)
