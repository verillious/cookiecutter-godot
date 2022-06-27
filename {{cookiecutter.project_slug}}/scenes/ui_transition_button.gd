class_name TransitionButton
extends Button

export(String, FILE, "*.tscn, *.scn") var scene


func _init() -> void:
	var err = connect("pressed", self, "_on_TransitionButton_pressed")
	assert(err == OK)


func _on_TransitionButton_pressed() -> void:
	Game.transition_scene(scene)
