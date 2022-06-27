class_name KeyBindingsEdit
extends GridContainer


func _init() -> void:
	set_process_unhandled_input(false)
	self.columns = 2


func _ready() -> void:
	for action in Game.settings.INPUT_ACTIONS:
		if InputMap.has_action(action):
			add_input_edit(action)
	for action in InputMap.get_actions():
		if not action in Game.settings.INPUT_ACTIONS:
			add_input_edit(action)


# create an input edit ui element for a given action string
# - `action`, `String`: the action to create the edit ui for
func add_input_edit(action: String) -> void:
	var label := Label.new()
	label.text = action
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(label)
	var action_list = InputMap.get_action_list(action)

	var input = null
	while action_list:
		input = action_list.pop_back()
		if input is InputEventKey or input is InputEventMouseButton:
			break
		else:
			input = null
	var input_edit = InputEdit.new(action, input)
	add_child(input_edit)
