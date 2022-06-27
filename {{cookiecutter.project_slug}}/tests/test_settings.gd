# test the settings ConfigFile wrapper
extends "res://addons/gut/test.gd"

var file = File.new()
var dir = Directory.new()


func before_each():
	if dir.file_exists("res://tests/config.ini"):
		dir.remove("res://tests/config.ini")


func after_each():
	if dir.file_exists("res://tests/config.ini"):
		dir.remove("res://tests/config.ini")


func test_load_file():
	var content = '[test]\n\nkey="value"\n'
	file.open("res://tests/config.ini", File.WRITE)
	file.store_string(content)
	file.close()

	var settings = Settings.new("res://tests/config.ini")

	assert_true(settings.has_section_key("test", "key"))
	assert_eq(settings.get_value("test", "key"), "value")


func test_set_value():
	var settings = Settings.new("res://tests/config.ini")
	settings.set_value("test", "key", "value")

	assert_true(dir.file_exists("res://tests/config.ini"))
	file.open("res://tests/config.ini", File.READ)
	assert_eq(file.get_as_text(), '[test]\n\nkey="value"\n')


func test_display_settings() -> void:
	var settings = Settings.new("res://tests/config.ini")
	settings.set_value("display", "fullscreen", true)
	settings.set_value("display", "fps_max", 999)
	settings.set_value("display", "cap_fps", true)
	settings.set_value("display", "vsync", true)

	assert_true(OS.window_fullscreen)
	assert_true(OS.vsync_enabled)
	assert_eq(Engine.target_fps, 999)

	settings.set_value("display", "cap_fps", false)

	assert_eq(Engine.target_fps, 0)


func test_input_settings() -> void:
	var settings = Settings.new("res://tests/config.ini")
	settings.set_value("input", "ui_up", 4)
	settings.set_value("input", "ui_down", 87)

	var ui_up_inputs = []
	for input in InputMap.get_action_list("ui_up"):
		if input is InputEventMouseButton or input is InputEventKey:
			ui_up_inputs.append(input)

	var ui_down_inputs = []
	for input in InputMap.get_action_list("ui_down"):
		if input is InputEventMouseButton or input is InputEventKey:
			ui_down_inputs.append(input)

	assert_eq(len(ui_up_inputs), 1)
	assert_eq(
		ui_up_inputs[0].as_text(),
		# gdlint:ignore = max-line-length
		"InputEventMouseButton : button_index=BUTTON_WHEEL_UP, pressed=false, position=(0, 0), button_mask=0, doubleclick=false"
	)

	assert_eq(len(ui_down_inputs), 1)
	assert_eq(ui_down_inputs[0].as_text(), "W")
