class_name QuitButton
extends Button


func _init() -> void:
	var err = connect("pressed", self, "_on_QuitButton_pressed")
	assert(err == OK)


func _on_QuitButton_pressed() -> void:
	Game.quit()
