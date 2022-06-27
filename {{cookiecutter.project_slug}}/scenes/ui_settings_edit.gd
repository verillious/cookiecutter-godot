extends Control

onready var _display_mode_button: OptionButton = find_node("OptionButtonDisplayMode")
onready var _vsync_button: CheckButton = find_node("CheckButtonVsync")
onready var _cap_fps_button: CheckButton = find_node("CheckButtonCapFPS")
onready var _fps_max_slider: HSlider = find_node("HSliderMaxFPS")


func _ready() -> void:
	_display_mode_button.selected = Game.settings.get_value("display", "fullscreen", false)
	_vsync_button.pressed = Game.settings.get_value("display", "vsync", false)
	_cap_fps_button.pressed = Game.settings.get_value("display", "cap_fps", false)
	_fps_max_slider.value = int(Game.settings.get_value("display", "fps_max", 0))


func _on_OptionButtonDisplayMode_item_selected(index: int) -> void:
	Game.settings.set_value("display", "fullscreen", bool(index))


func _on_CheckButtonVsync_toggled(button_pressed: bool) -> void:
	Game.settings.set_value("display", "vsync", button_pressed)


func _on_CheckButtonCapFPS_toggled(button_pressed: bool) -> void:
	Game.settings.set_value("display", "cap_fps", button_pressed)


func _on_HSliderMaxFPS_value_changed(value: float) -> void:
	Game.settings.set_value("display", "fps_max", int(value))
	_fps_max_slider.value = int(value)


func _on_HSliderMainVolume_value_changed(value: float) -> void:
	Game.settings.set_value("audio", "main_volume", int(value))


func _on_HSliderMusicVolume_value_changed(value: float) -> void:
	Game.settings.set_value("audio", "music_volume", int(value))


func _on_HSliderSFXVolume_value_changed(value: float) -> void:
	Game.settings.set_value("audio", "sfx_volume", int(value))
