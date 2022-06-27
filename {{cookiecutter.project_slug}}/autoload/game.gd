# the root game manager class
# holds references to a lot of utility classes
extends ColorRect

const MOD_PATH = "user://mods/"
const LOAD_ORDER_FILE_PATH = "user://mods/loadorder.txt"

# scene manager singleton
var scenes := Scenes.new()

# console window
var console := Console.new()

# logger singleton
var logger := Logger.new()

# settings singleton
var settings := Settings.new()

# tracks the pause state of the game
var paused := false setget set_paused


func _init() -> void:
	_load_mods()
	pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(scenes)
	add_child(console)
	theme = load("res://resources/theme_main.tres")


func _ready() -> void:
	get_tree().set_auto_accept_quit(false)


func _notification(what) -> void:
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		quit()


# load a scene path instance and make it the current scene
# - `target_scene_path`, `String`: the path to the scene file that should be loaded
func transition_scene(target_scene_path: String) -> void:
	set_paused(true)
	logger.info("Transitioning scene to %s" % target_scene_path)
	scenes.transition_scene(target_scene_path)
	set_paused(false)


# toggle the whether the game is paused
func toggle_pause() -> void:
	set_paused(!paused)


# set whether the game is paused
# - `_paused`, `bool`: whether the game should be paused or not
func set_paused(_paused: bool) -> void:
	paused = _paused
	get_tree().paused = paused


# close the game
func quit() -> void:
	logger.info("Quitting ...")
	get_tree().quit()


# assign an input action to a given input event
# - `action`, `String`: the action name
# - `input`, `InputEvent`: the input event to assign to the action
func set_action_input_event(action: String, input: InputEvent) -> void:
	var code = input.get("scancode")
	code = code if code else input.get("button_index")
	settings.set_value("input", action, code)


# load mod `.pck` files in a given load order
func _load_mods() -> void:
	var load_order := []
	var file = File.new()
	var err = file.open(LOAD_ORDER_FILE_PATH, File.READ)

	if not err == OK:
		logger.warning("Could not read %s" % LOAD_ORDER_FILE_PATH)
		return

	while not file.eof_reached():
		var line = file.get_line()
		if line:
			load_order.append(line.strip_edges())
	file.close()

	for mod_file in load_order:
		var loaded = ProjectSettings.load_resource_pack("%s%s" % [MOD_PATH, mod_file])
		if not loaded:
			logger.warning("Could not load %s" % mod_file)
		else:
			logger.info("Loaded %s" % mod_file)
