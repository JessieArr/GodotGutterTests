extends Node
class_name Asserter

static var failed = false;

static func myAssert(value: bool):
	if value != true:
		failed = true
