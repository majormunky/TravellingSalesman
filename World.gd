extends Node2D

const MAX_POINTS = 11
var points = []
var solutions = []
var best_solution = null
var best_score = 1000000000
var state = "started"
var debug_solutions = {}
var debug_index = 0

onready var Town = preload("res://Town.tscn")
onready var Line = preload("res://Line.tscn")
onready var line_container = $LineContainer
onready var score_label = $Panel/VBoxContainer/ScoreLabel
onready var solutions_label = $Panel/VBoxContainer/SolutionsLabel
onready var panel = $Panel
onready var point_container = $PointContainer
onready var time_label = $Panel/VBoxContainer/TimeLabel

func _ready():
	pass # Replace with function body.


func generate_solutions(point_list, item_count):
	state = "have_solution"
	if item_count == 1:
		evaluate_solution()
	else:
		var swap_index
		var temp_point
		for i in range(item_count):
			generate_solutions(point_list, item_count - 1)
			if (i % 2) == 0:
				swap_index = i
			else:
				swap_index = 0
			temp_point = points[swap_index]
			points[swap_index] = points[item_count-1]
			points[item_count-1] = temp_point
			

func evaluate_solution():
	var score = 0
	
	var i = 0
	var total_points = len(points)
	for point in points:
		if i + 1 < total_points:
			score += point.distance_to(points[i + 1])
			i += 1
	
	score += points[0].distance_to(points[-1])
	
	debug_solutions[score] = points.duplicate()
	
	if score < best_score:
		# print("Found lower score! -> (old=", best_score, "), (new=", score, ")")
		best_solution = points.duplicate()
		best_score = score
	else:
		pass
		#print("Score was higher than our best, skipping: ", score)
	

func draw_solution(s):
	for child in line_container.get_children():
		line_container.remove_child(child)

	var new_line = Line.instance()
	for a_point in s:
		new_line.add_point(a_point)
	new_line.add_point(s[0])
	line_container.add_child(new_line)


func _input(event):
	if state == "have_solution":
		return

	if event is InputEventMouseButton and event.is_pressed():
		if event.position.x < 150:
			return
		
		if len(points) >= MAX_POINTS:
			return
		
		points.append(event.position)
		var new_town = Town.instance()
		new_town.position = event.position
		point_container.add_child(new_town)


func _on_Button_pressed():
	if len(points) <= 2:
		return
	
	if state == "have_solution":
		return
	
	var start = OS.get_system_time_msecs()
	
	generate_solutions(points, len(points) - 1)
	draw_solution(best_solution)
	update_score_label(best_score)
	solutions_label.text = "Solutions: " + str(len(debug_solutions))
	
	$Panel/ButtonContainer/VBoxContainer/NextButton.disabled = false
	$Panel/ButtonContainer/VBoxContainer/PrevButton.disabled = false
	$Panel/ButtonContainer/VBoxContainer/RunButton.disabled = true
	
	var end = OS.get_system_time_msecs()
	var diff = end - start
	time_label.text = "Time: " + str(diff / 1000.0)


func update_score_label(score):
	if score == 0:
		score_label.text = "Score: 0\nBest: 0"
	else:
		score_label.text = "Score: " + str(int(score)) + "\nBest: " + str(int(best_score))

func _on_PrevButton_pressed():
	var score_keys = debug_solutions.keys()
	score_keys.sort()
	debug_index -= 1
	
	if debug_index < 0:
		debug_index = len(score_keys) - 1
	var selected_key = score_keys[debug_index]
	draw_solution(debug_solutions[selected_key])
	update_score_label(selected_key)


func _on_NextButton_pressed():
	# print(debug_solutions)
	var score_keys = debug_solutions.keys()
	score_keys.sort()
	debug_index += 1	
	
	if debug_index >= len(score_keys):
		debug_index = 0

	var selected_key = score_keys[debug_index]
	draw_solution(debug_solutions[selected_key])
	update_score_label(selected_key)


func _on_ResetButton_pressed():
	points = []
	solutions = []
	best_solution = null
	best_score = 1000000000

	debug_solutions = {}
	debug_index = 0
	
	for child in point_container.get_children():
		point_container.remove_child(child)
	
	for child in line_container.get_children():
		line_container.remove_child(child)

	update_score_label(0)
	solutions_label.text = "Solutions: 0"
	time_label.text = "Time: 0"
	state = "started"
	
	$Panel/ButtonContainer/VBoxContainer/NextButton.disabled = true
	$Panel/ButtonContainer/VBoxContainer/PrevButton.disabled = true
	$Panel/ButtonContainer/VBoxContainer/RunButton.disabled = false
