extends PopupPanel

onready var settings_popup = find_node("PopupPanelSettings")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle()


func toggle() -> void:
	if settings_popup.visible:
		settings_popup.hide()
		return

	Game.toggle_pause()
	if Game.paused:
		popup_centered_ratio()
	else:
		hide()


func _on_ButtonSettings_pressed() -> void:
	settings_popup.popup_centered_ratio()
