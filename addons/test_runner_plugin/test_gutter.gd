@tool
extends EditorPlugin

var script_editor: Control
var code_edit: CodeEdit
var currentScript: String
var currentGutterIndex: int
var originalPushError

func _enter_tree():
	print("Hello")
	# Get the script editor
	script_editor = get_editor_interface().get_script_editor()
	script_editor.editor_script_changed.connect(on_script_changed)
	script_editor.script_close.connect(on_script_closed)
	
	code_edit = get_code_edit(script_editor)
	if code_edit:
		add_gutter(code_edit)

func _exit_tree():
	code_edit.remove_gutter(currentGutterIndex)
	print("Goodbye!")

func get_code_edit(script_editor: ScriptEditor) -> CodeEdit:
	var editor := script_editor.get_current_editor()
	if editor and editor.has_method("get_base_editor"):
		return editor.get_base_editor()  # Returns the CodeEdit instance
	return null

func add_gutter(code_edit: CodeEdit):
	currentGutterIndex = code_edit.get_gutter_count()
	code_edit.add_gutter(currentGutterIndex)
	code_edit.set_gutter_name(currentGutterIndex, "Tests")
	code_edit.connect("gutter_clicked", on_line_clicked)

func add_button_to_gutter(code_edit: CodeEdit, line: int):
	code_edit.set_line_gutter_clickable(line, currentGutterIndex, true)
	code_edit.set_line_gutter_text(line, currentGutterIndex, "➡️")

func add_success_to_gutter(code_edit: CodeEdit, line: int):
	code_edit.set_line_gutter_clickable(line, currentGutterIndex, true)
	code_edit.set_line_gutter_text(line, currentGutterIndex, "🟢")

func add_failure_to_gutter(code_edit: CodeEdit, line: int):
	code_edit.set_line_gutter_clickable(line, currentGutterIndex, true)
	code_edit.set_line_gutter_text(line, currentGutterIndex, "🔴")

func read_script_lines(script_path: String):
	var file = FileAccess.open(script_path, FileAccess.READ)
	var currentLine = 0;
	if not file:
		print("Failed to open file: ", script_path)
		return
	while not file.eof_reached():
		var line = file.get_line()
		if line.begins_with("func test_"):
			add_button_to_gutter(code_edit, currentLine)
		else:
			code_edit.set_line_gutter_text(currentLine, currentGutterIndex, "")
		currentLine = currentLine + 1

func read_specific_line(file_path: String, line_number: int) -> String:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("Failed to open file: ", file_path)
		return ""
	var current_line = 0
	while not file.eof_reached():
		var line = file.get_line()
		if current_line == line_number:
			return line
		current_line += 1
	
	return ""  # Return empty if the line number is out of range

func on_script_changed(arg: GDScript):
	print("script changed")
	code_edit.remove_gutter(currentGutterIndex)
	code_edit.disconnect("gutter_clicked", on_line_clicked)
	currentScript = arg.resource_path
	code_edit = get_code_edit(script_editor)
	add_gutter(code_edit)
	read_script_lines(currentScript)

func on_script_closed(arg: GDScript):
	print("script closed")
	currentScript = ""

func on_line_clicked(line: int, gutterIndex: int):
	var script = ResourceLoader.load(currentScript)
	if script:
		var instance = script.new()
		var lineText = read_specific_line(currentScript, line)
		if lineText.begins_with("func test_"):
			var parenPosition = lineText.find("(")
			var functionName = lineText.substr(5, parenPosition - 5)			
			instance.call(functionName)
			if Asserter.failed:
				add_failure_to_gutter(code_edit, line)
			else:
				add_success_to_gutter(code_edit, line)
			Asserter.failed = false
		else:
			print("no test found on clicked line")
	else:
		print("Failed to load script")
