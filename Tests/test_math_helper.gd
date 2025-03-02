extends Node

# Load the script under test
var math_helper = preload("res://Scripts/math_helper.gd").new()

func test_addition():
	var result = math_helper.add(5, 8)
	print("addition complete")

func test_something_else():
	print("something else")
	assert(false)
