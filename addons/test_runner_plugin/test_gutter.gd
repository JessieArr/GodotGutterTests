@tool
extends EditorPlugin

var script_editor: Control
var code_edit: CodeEdit

func _enter_tree():
	print("Hello")
	# Get the script editor
	script_editor = get_editor_interface().get_script_editor()
	script_editor.editor_script_changed.connect(on_script_changed)
	script_editor.script_close.connect(on_script_closed)
	
	code_edit = get_code_edit(script_editor)
	if code_edit:
		print("adding gutter")
		code_edit.add_gutter(1)
		add_button_to_gutter(code_edit)

func _exit_tree():
	print("Goodbye!")

func get_code_edit(script_editor: ScriptEditor) -> CodeEdit:
	print("looking for code edit")
	var editor := script_editor.get_current_editor()
	print(editor)
	if editor and editor.has_method("get_base_editor"):
		print("returning code edit")
		return editor.get_base_editor()  # Returns the CodeEdit instance
	return null

func add_button_to_gutter(code_edit: CodeEdit):
	print("Adding button")
	# Create a button
	var button = Button.new()
	button.text = "Click Me"
	
	code_edit.set_line_gutter_clickable(1, 1, true)
	code_edit.set_line_gutter_text(1, 1, "➡️")
	code_edit.set_gutter_name(1, "Tests")
	code_edit.connect("gutter_clicked", on_line_clicked)

func _on_button_pressed(line: int):
	print("Button clicked on line:", line + 1)

func on_script_changed(arg: GDScript):
	print("script changed")
	print(arg.resource_path)

func on_script_closed(arg: GDScript):
	print("script closed")
	print(arg.resource_path)

func on_line_clicked(first, second):
	print("line clicked")
	print(first)
	print(second)
	var script = ResourceLoader.load("res://Tests/test_math_helper.gd")
	if script:
		var instance = script.new()
		instance.test_addition()
	else:
		print("Failed to load script")
	
