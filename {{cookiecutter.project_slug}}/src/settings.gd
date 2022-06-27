# a ConfigFile wrapper that automatically saves and loads from user://config.ini
class_name Settings
extends ConfigFile

signal value_set(section, key, value)
signal value_erased(section, key)

# the file we will read and write from
const DEFAULT_FILE_PATH := "user://config.ini"

# array of inputs that _must_ exist
const INPUT_ACTIONS := [
	"ui_accept",
	"ui_select",
	"ui_cancel",
	"ui_focus_next",
	"ui_focus_prev",
	"ui_left",
	"ui_right",
	"ui_up",
	"ui_down",
	"ui_page_up",
	"ui_page_down",
	"ui_home",
	"ui_end"
]

var file_path := DEFAULT_FILE_PATH


# load from user://config.ini by default
# - path, String: path to the config file to use
func _init(path := DEFAULT_FILE_PATH) -> void:
	file_path = path
	var file = File.new()

	if file.file_exists(file_path):
		var err = .load(file_path)
		if not err == OK:
			Game.logger.error("Error loading %s" % file_path)

	_apply_display_settings()
	_apply_all_input_settings()


# set value and save to user://config.ini
# - section, String: the section to store this entry under
# - key, String: the name of this entry
# - value, Variant: the value of this entry
func set_value(section: String, key: String, value) -> void:
	Game.logger.debug("Setting %s/%s to %s" % [section, key, value])
	.set_value(section, key, value)

	# saving every time we edit a value might be a bit inefficient but we don't really edit
	# config.ini enough for it to matter and having the assurance that the disc copy is always
	# up to date is nice.
	var err = save(file_path)
	if not err == OK:
		Game.logger.error("Error saving config.ini")

	match section:
		"display":
			_apply_display_settings()
		"input":
			_apply_input_setting(key, value)
	emit_signal("value_set", section, key, value)


# deletes the specified section along with all the key-value pairs inside
# emits the `value_erased` signal for each of them
# - `section`, `String`: the section to erase
func erase_section(section: String) -> void:
	Game.logger.debug("Erasing section %s" % section)
	for key in get_section_keys(section):
		emit_signal("value_erased", section, key)
	.erase_section(section)


# deletes the specified key in a section
# emits the `value_erased` signal
# - `section`, `String`: the section to erase in
# - `key`, `String`: the key to erase
func erase_section_key(section: String, key: String) -> void:
	print("Erasing %s/%s" % [section, key])
	.erase_section_key(section, key)
	emit_signal("value_erased", section, key)


# convert a scancode/button_index into an InputEvent
func get_input_event_from_code(code: int) -> InputEvent:
	var event
	if code < 10:
		event = InputEventMouseButton.new()
		event.button_index = code
	else:
		event = InputEventKey.new()
		event.scancode = code
	return event


# internal function which applies display settings
# sets up fullsceen, vsync, fps cap etc.
func _apply_display_settings() -> void:
	if has_section("display"):
		OS.window_fullscreen = get_value("display", "fullscreen", false)
		OS.set_use_vsync(get_value("display", "vsync", false))
		var fps_cap = (
			get_value("display", "fps_max", 0)
			if get_value("display", "cap_fps", false)
			else 0
		)
		Engine.set_target_fps(fps_cap)


# internal function which applies _all_ input action settings
func _apply_all_input_settings() -> void:
	if has_section("input"):
		for key in get_section_keys("input"):
			if has_section_key("input", key):
				var code = get_value("input", key)
				_apply_input_setting(key, code)


# internal function which applies an input action setting
func _apply_input_setting(key: String, code: int) -> void:
	# leave the controller stuff
	for input_event in InputMap.get_action_list(key):
		if input_event is InputEventMouseButton or input_event is InputEventKey:
			InputMap.action_erase_event(key, input_event)

	_unassign_input_event(code)
	InputMap.action_add_event(key, get_input_event_from_code(code))


# internal function which unassigns an input action setting
func _unassign_input_event(code: int) -> void:
	if has_section("input"):
		for key in get_section_keys("input"):
			if get_value("input", key) == code:
				erase_section_key("input", key)
				InputMap.action_erase_event(key, get_input_event_from_code(code))
