extends Node
class_name Asserter

static func myAssert(value: bool):
	if value != true:
		print("assertion failed")
	else:
		print("success!")
