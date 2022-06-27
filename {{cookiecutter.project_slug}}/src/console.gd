# an in-game console dialog
# use `connect_node()` on a node to register all functions that end with _cmd as commands
# functions that are registered as commands should always accept a `Console` singleton
# as their first argument
class_name Console
extends WindowDialog

# dictionary of command funcrefs and arg counts
var commands := {}

# an array of commands that have been entered
var history := PoolStringArray([])

# the output log
var label := RichTextLabel.new()

# the input line edit
var line := LineEdit.new()

# records the current index in the history
var current_history_index := 0

# whether the user is currently requesting autocomplete results
var _autocomplete_running := false

# the possible results of our current autocomplete call
var _autocomplete_results := []

# the current index of autocomplete results that are being cycled
var _autocomplete_index := 0

# the original autocomplete search string
var _autocomplete_search: String


func _init() -> void:
	# connect the default set of commands
	connect_node(self)

	# setup the UI
	window_title = "console"
	resizable = true
	rect_min_size = Vector2(200, 100)
	rect_size = Vector2(500, 300)
	rect_position = Vector2(100, 100)

	var c := VBoxContainer.new()
	c.anchor_bottom = 1
	c.anchor_left = 0
	c.anchor_top = 0
	c.anchor_right = 1

	label.bbcode_enabled = true
	label.size_flags_vertical = SIZE_EXPAND_FILL
	label.scroll_following = true
	label.selection_enabled = true
	label.focus_mode = FOCUS_NONE
	label.fit_content_height = false
	label.bbcode_enabled = true

	add_child(c)
	c.add_child(label)
	c.add_child(line)

	var err := line.connect("text_entered", self, "_command")
	assert(err == OK)

	err = line.connect("text_changed", self, "_on_line_text_changed")
	assert(err == OK)

	err = line.connect("gui_input", self, "_gui_input")
	assert(err == OK)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		var event_key: InputEventKey = event
		match event_key.scancode:
			KEY_APOSTROPHE, KEY_ASCIITILDE:
				accept_event()
				if visible:
					hide()
				else:
					show()
					line.clear()
					line.grab_focus()
					raise()


func _gui_input(event: InputEvent) -> void:
	accept_event()
	if event is InputEventKey and event.is_pressed():
		var event_key: InputEventKey = event

		match event_key.scancode:
			KEY_UP:
				if history.size() > 0:
					current_history_index = int(
						clamp(current_history_index - 1, 0, history.size() - 1)
					)
					line.text = history[current_history_index]
					line.caret_position = line.text.length()
			KEY_DOWN:
				if history.size() > 0:
					current_history_index = int(
						clamp(current_history_index + 1, 0, history.size() - 1)
					)
					line.text = history[current_history_index]
					line.caret_position = line.text.length()
			KEY_TAB:
				var command_segs = line.text.split(" ")
				if command_segs.size() == 1:
					if _autocomplete_running:
						_autocomplete_index += 1
						if _autocomplete_index >= len(_autocomplete_results):
							_autocomplete_index = 0
					else:
						self._autocomplete_running = true
						_autocomplete_index = 0
						_autocomplete_search = line.text
						_autocomplete_results = _autocomplete(line.text)

					if _autocomplete_results:
						var new_command = "%s " % _autocomplete_results[_autocomplete_index][1]
						line.set_text(new_command)
						line.caret_position = len(new_command)


# parse a node for functions that end with '_cmd'
# create a funcref for those that do, and assign them to a console command
# - `node`, `Node`: the node to parse for commands
func connect_node(node: Node) -> void:
	for method in node.get_method_list():
		var method_name: String = method.name
		if method_name.ends_with("_cmd"):
			var clean_name := method_name.trim_prefix("_").trim_suffix("_cmd")
			commands[clean_name] = {
				"ref": funcref(node, method_name), "args_amount": method.args.size()
			}


# write bbcode to the console log
# - `bbcode`, `String`: the bbcode string to write to the console log
# - `color`, `Color`: the Color to wrap the bbcode in.
#   If transparent then use default color (default: `Color.transparent`)
func write(bbcode: String, color: Color = Color.transparent) -> void:
	var final_bbcode := _color_wrap("%s" % bbcode, color) if color != Color.transparent else bbcode
	var err := label.append_bbcode("\n" + final_bbcode)
	assert(err == OK)


# write an error to the console
# - `bbcode`, `String`: the bbcode string to write to the console log
func error(bbcode: String) -> void:
	write("[b]%s[/b]" % bbcode, Color.crimson)


# write a warning to the console
# - `bbcode`, `String`: the bbcode string to write to the console log
func warning(bbcode: String) -> void:
	write("[b]%s[/b]" % bbcode, Color.orange)


# run a console command string
# - `cmd`, `String`: the command and any arguments as a space seperated string
func _command(cmd: String) -> void:
	if cmd == "":
		return

	line.clear()
	cmd = cmd.strip_edges()
	self.write(str("\n" if label.text.length() != 0 else "", "> ", cmd))

	var args = Array(cmd.split(" "))
	var key = args.pop_front()

	for i in args.size():
		var arg: String = args[i]
		var new_arg = arg
		if arg.to_lower() == "false":
			new_arg = false
		elif arg.to_lower() == "true":
			new_arg = true
		elif arg.is_valid_float():
			new_arg = float(arg)
		elif arg.is_valid_integer():
			new_arg = int(arg)
		args[i] = new_arg

	var command: Dictionary = commands.get(key, {})
	if command:
		var final := [self]
		final.append_array(args)
		final.resize(command.args_amount)
		command.ref.call_funcv(final)
	else:
		_cmd_not_found(key)

	history.append(cmd)
	current_history_index = history.size()


# wrap a bbcode string in a color tag
# - `bbcode`, `String`: the bbcode string to wrap
# - `color`, `Color`: the color to wrap the string in
# - returns String: the wrapped bbcode string
func _color_wrap(bbcode: String, color: Color) -> String:
	return "[color=#%s]%s[/color]" % [color.to_html(), bbcode]


# informs the user that a command is not valid and suggests alternatives
# - `command`, `String`: the command that is not valid
func _cmd_not_found(command: String) -> void:
	self.error("Command '%s' not found - possible alternatives:" % command)
	var results := _autocomplete(command)
	for result in results:
		self.write("\t%s" % result[1])


# generate a list of potential options for an autocomplete request
# - `command_name`, `String`: the string to search with
# - `command_keys`, `Array`: an array of command name strings to search against
#   (default: all registered command names)
# - returns `Array`: a list of options sorted by similarity to the search string
func _autocomplete(command_name: String, command_keys: Array = commands.keys()) -> Array:
	var order := []

	for string in command_keys:
		# warning-ignore:unsafe_method_access
		var dist := command_name.similarity(string)
		if dist > 0:
			order.append([dist, string])

	order.sort_custom(self, "_sort_dist")
	return order


func _sort_dist(a, b):
	return a[0] > b[0]


# resets autocomplete status when the user inputs text
# - `_text`, `String`: the contents of the line edit (ignored)
func _on_line_text_changed(_text: String) -> void:
	_autocomplete_running = false


# print a list of available commands
# - `console`, `Console`: a console instance
func _help_cmd(console: Console) -> void:
	var keys := commands.keys()
	keys.sort()
	for cmd in keys:
		console.write(cmd)


# print the command history
# - `console`, `Console`: a console instance
func _history_cmd(console: Console) -> void:
	console.write(history.join("\n"))


# clear the console log
# - `console`, `Console`: a console instance
func _clear_cmd(console: Console) -> void:
	console.label.clear()


# close the console
# - `console`, `Console`: a console instance
func _exit_cmd(console: Console) -> void:
	console.hide()
