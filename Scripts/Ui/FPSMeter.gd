extends Control

const MAX_POINTS = 100
const CHART_SIZE = Vector2(200, 75)
const UPDATE_INTERVAL = 0.5

var points = []
var time_since_last_update = 0.0
var highest_fps = 0.0
var lowest_fps = INF
var total_fps = 0.0
var last_frame_count = 0
var fps_history = []
var low_1_percent = 0.0
var last_frames = 0

@onready var label: Label = $CanvasLayer/Label
@onready var default_font = get_theme_default_font()

func _ready():
	for i in range(MAX_POINTS):
		points.append(Vector2.ZERO)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	last_frame_count = Engine.get_frames_drawn()

func _process(delta):
	time_since_last_update += delta
	if time_since_last_update >= UPDATE_INTERVAL:
		update_fps_data()
		update_label()
		update_points()
		time_since_last_update = 0
		queue_redraw()

func update_fps_data():
	var current_frame_count = Engine.get_frames_drawn()
	var frames_elapsed = current_frame_count - last_frame_count
	var fps = frames_elapsed / UPDATE_INTERVAL
	
	highest_fps = max(highest_fps, fps)
	lowest_fps = min(lowest_fps, fps)
	total_fps += fps
	fps_history.append(fps)
	if fps_history.size() > 100:
		total_fps -= fps_history.pop_front()
	
	var sorted_history = fps_history.duplicate()
	sorted_history.sort()
	var low_1_percent_index = max(0, ceil(sorted_history.size() * 0.01) - 1)
	low_1_percent = sorted_history[low_1_percent_index]
	
	last_frame_count = current_frame_count

func update_label():
	var avg_fps = total_fps / fps_history.size()
	label.text = "FPS: %d\nAvg FPS: %d\n1%% Low: %d" % [
		Engine.get_frames_per_second(),
		round(avg_fps),
		round(low_1_percent)
	]
	var viewport_size = get_viewport_rect().size
	label.position = Vector2(viewport_size.x - label.size.x - CHART_SIZE.x - 20, 10)

func update_points():
	for i in range(MAX_POINTS - 1):
		points[i] = points[i + 1]
	points[MAX_POINTS - 1] = Vector2(MAX_POINTS - 1, Engine.get_frames_per_second())

func _draw():
	var viewport_size = get_viewport_rect().size
	var chart_position = Vector2(viewport_size.x - CHART_SIZE.x - 10, 10)
	draw_chart_background(chart_position)
	draw_chart_grid(chart_position)
	draw_fps_graph(chart_position)
	draw_fps_labels(chart_position)

func draw_chart_background(pos):
	draw_rect(Rect2(pos, CHART_SIZE), Color(0.1, 0.1, 0.1))

func draw_chart_grid(pos):
	for i in range(5):
		var y = pos.y + CHART_SIZE.y - (i * CHART_SIZE.y / 4)
		draw_line(Vector2(pos.x, y), Vector2(pos.x + CHART_SIZE.x, y), Color(0.3, 0.3, 0.3))
	for i in range(10):
		var x = pos.x + (i * CHART_SIZE.x / 9)
		draw_line(Vector2(x, pos.y), Vector2(x, pos.y + CHART_SIZE.y), Color(0.3, 0.3, 0.3))

func draw_fps_labels(pos):
	var current_min_fps = points.min().y
	var current_max_fps = points.max().y
	for i in range(4):
		var fps_value = current_min_fps + (current_max_fps - current_min_fps) * i / 4
		var y = pos.y + CHART_SIZE.y - (i * CHART_SIZE.y / 4)    
		draw_string(default_font, Vector2(pos.x, y), str(round(fps_value)), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.7, 0.7, 0.7))

func draw_fps_graph(pos):
	var current_min_fps = points.min().y
	var current_max_fps = points.max().y
	if current_max_fps >= current_min_fps:
		var prev_point = null
		for i in range(MAX_POINTS):
			var current_point = Vector2(
				pos.x + CHART_SIZE.x * i / (MAX_POINTS - 1),
				pos.y + CHART_SIZE.y / 2
			)
			if current_max_fps > current_min_fps:
				current_point.y = pos.y + CHART_SIZE.y - ((points[i].y - current_min_fps) / (current_max_fps - current_min_fps) * CHART_SIZE.y)
			
			if prev_point != null:
				var start = Vector2(
					clamp(prev_point.x, pos.x, pos.x + CHART_SIZE.x),
					clamp(prev_point.y, pos.y, pos.y + CHART_SIZE.y)
				)
				var end = Vector2(
					clamp(current_point.x, pos.x, pos.x + CHART_SIZE.x),
					clamp(current_point.y, pos.y, pos.y + CHART_SIZE.y)
				)
				draw_line(start, end, Color(0, 1, 0), 2)
			prev_point = current_point
