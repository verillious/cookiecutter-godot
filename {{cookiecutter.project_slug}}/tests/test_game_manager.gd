# test the game manager singleton class
extends "res://addons/gut/test.gd"


# test that we can transition to a scene path
func test_transition_scene():
	Game.transition_scene("res://tests/test_scenes/test.tscn")
	yield(Game.scenes, "scene_changed")
	assert_not_null(Game.scenes.current_scene)
	assert_eq(get_tree().current_scene, Game.scenes.current_scene)
	assert_eq(Game.scenes.current_scene.get_script().get_path(), "res://tests/test_scenes/test.gd")
