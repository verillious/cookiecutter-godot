class_name InputEdit
extends Button

# human readable description of mouse button indexes
const MOUSE_BUTTON_TEXT := [
	"Left Mouse Button",
	"Right Mouse Button",
	"Middle Mouse Button",
	"Mouse Wheel Up",
	"Mouse Wheel Down",
	"Mouse Wheel Left",
	"Mouse Wheel Right",
	"Mouse Button 5",
	"Mouse Button 6",
]

# the action that this input edit refers to
var action: String

# a reference to the current input action this input edit is assigned to
var input: InputEvent


# set up the current action and input event
# - `_action`, `String`: the action this edit is assigned to
# - `_input_event`, `InputEvent`: the current input event (default: null)
func _init(_action: String, _input_event: InputEvent = null) -> void:
	set_process_input(false)
	action = _action
	input = _input_event
	text = get_input_text(input) if input else "none"

	var err = connect("pressed", self, "_on_InputEdit_pressed")
	assert(err == OK)

	err = Game.settings.connect("value_set", self, "_on_Settings_value_set")
	assert(err == OK)

	flat = true
	align = ALIGN_LEFT
	size_flags_horizontal = SIZE_EXPAND_FILL


# disable processing input until we're ready
func _ready() -> void:
	set_process_input(false)


# listen for an input event
# - `event`, `InputEvent`: the detected input event
func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		if event.is_pressed():
			accept_event()
			set_process_input(false)
			set_input(event)


# get a human readable description of an input event
# - `input_event`, `InputEvent`: the input event to get a description for
# - returns `String`: the human readable description
func get_input_text(input_event: InputEvent) -> String:
	if input_event is InputEventKey:
		return input_event.as_text()
	elif input_event is InputEventMouseButton:
		var input_event_mouse: InputEventMouseButton = input_event
		return MOUSE_BUTTON_TEXT[input_event_mouse.button_index - 1]
	return input_event.as_text()


# assign the current input event
# - `input_event`, `InputEvent`: the input event to assign
func set_input(input_event: InputEvent) -> void:
	if input_event:
		Game.set_action_input_event(action, input_event)
		text = get_input_text(input_event)
	else:
		text = get_input_text(input)


# start listening for input
func _on_InputEdit_pressed() -> void:
	text = "Press a key..."
	self.set_process_input(true)


# reset if our input_event is used elsewhere
func _on_Settings_value_set(section: String, key: String, value) -> void:
	if section == "input":
		if key != action and (value == input.get("scancode") or value == input.get("button_index")):
			text = "none"
			input = null
