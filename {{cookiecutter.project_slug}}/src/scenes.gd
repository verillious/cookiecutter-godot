# scene manager class
# Controls scene transitions and holds a reference to the current scene
class_name Scenes
extends Node

# emitted when the scene has been successfully emitted
signal scene_changed

# the current scene-load progress
var progress := 100.0 setget , get_progress

# the poll time interval
var _time_max := 100  # msec

# the current resourceloader
var _loader = null

# the current amount of frames before loading (to allow for animations to start etc.)
var _wait_frames := 0

# reference to the topmost node in the scenetree
onready var current_scene: Node


# allow this node to process when the game is paused
func _init() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS


# get a reference to the current scene when we enter the tree
func _enter_tree() -> void:
	if not current_scene:
		current_scene = get_tree().current_scene


# if we have a current resource loader, poll it and resolve the results
# - _time, float: the time since the last _process call (ignored)
func _process(_time: float) -> void:
	# no need to process anymore
	if _loader == null:
		set_process(false)
		return

	# wait for frames to let the "loading" animation show up.
	if _wait_frames > 0:
		_wait_frames -= 1
		return

	var t = OS.get_ticks_msec()

	while OS.get_ticks_msec() < t + _time_max:
		var err = _loader.poll()

		if err == ERR_FILE_EOF:  # finished loading
			var resource = _loader.get_resource()
			_loader = null
			set_current_scene(resource.instance())
			break
		elif err == OK:
			_update_progress()
		else:  # error during loading
			_loader = null
			break


# load a scene path instance and make it the current scene
# - target_scene_path, String: the path to the scene to load and change to
func transition_scene(target_scene_path: String) -> void:
	_loader = ResourceLoader.load_interactive(target_scene_path)
	if _loader == null:  # Check for errors.
		return
	set_process(true)
	_wait_frames = 1


# remove the current topmost node and add new_scene under the root
# - new_scene, Node: the new node to use as the current scene
func set_current_scene(new_scene: Node) -> void:
	if self.current_scene and is_instance_valid(self.current_scene):
		self.current_scene.queue_free()
	get_tree().root.add_child(new_scene)
	current_scene = new_scene
	get_tree().set("current_scene", new_scene)
	emit_signal("scene_changed")


# get the topmost node in the scenetree
func get_current_scene() -> Node:
	return current_scene


# get the current progress of the resource loader
func get_progress() -> float:
	if _loader:
		return float(_loader.get_stage()) / _loader.get_stage_count()
	return 100.0


# do something with the current progress
func _update_progress() -> void:
	Game.logger.info("Load progress: %s" % self.progress)
