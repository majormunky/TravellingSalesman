extends Node2D

var points = []
var solutions = []
var best_solution = null
var best_score = 1000000000

var debug_solutions = []
var debug_index = 0

onready var Town = preload("res://Town.tscn")
onready var Line = preload("res://Line.tscn")
onready var LineContainer = $LineContainer
onready var score_label = $Panel/ScoreLabel

func _ready():
	pass # Replace with function body.


func generate_solutions(point_list, item_count):
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
	
	debug_solutions.append([score, points.duplicate()])
	
	if score < best_score:
		# print("Found lower score! -> (old=", best_score, "), (new=", score, ")")
		best_solution = points.duplicate()
		best_score = score
	else:
		pass
		#print("Score was higher than our best, skipping: ", score)
	

func draw_solution(s):
	for child in LineContainer.get_children():
		LineContainer.remove_child(child)

	var new_line = Line.instance()
	for a_point in s:
		new_line.add_point(a_point)
	new_line.add_point(s[0])
	LineContainer.add_child(new_line)
	
	


func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.position.y > 500:
			return
		points.append(event.position)
		var new_town = Town.instance()
		new_town.position = event.position
		add_child(new_town)


func _on_Button_pressed():
	if len(points) <= 2:
		return
	generate_solutions(points, len(points) - 1)
	draw_solution(best_solution)
	update_score_label(best_score)


func update_score_label(score):
	score_label.text = "Score: " + str(int(score)) + " Best: " + str(int(best_score))


func _on_PrevButton_pressed():
	pass # Replace with function body.


func _on_NextButton_pressed():
	# print(debug_solutions)
	debug_index += 1
	draw_solution(debug_solutions[debug_index][1])
	update_score_label(debug_solutions[debug_index][0])
	# print("Drawing next solution")