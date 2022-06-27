class_name SliderLabel
extends Label

enum VisibilityRule { ON_CLICK, ON_HOVER, ON_FOCUS, ALWAYS }
enum Placement { TOP_RIGHT, BOTTOM_LEFT }

const SLIDER_WARNING = "SliderLabel needs to be a child of a Slider."
const SLIDER_WARNING2 = "custom_slider_path needs to point to a Slider."

export(VisibilityRule) var visibility_rule: int = VisibilityRule.ON_HOVER
export(Placement) var placement: int = Placement.TOP_RIGHT
export var separation := 4

var slider: Slider
var vertical: bool


func _init() -> void:
	align = Label.ALIGN_CENTER
	valign = Label.VALIGN_CENTER
	size_flags_horizontal = SIZE_SHRINK_CENTER
	text = "100"


func _ready() -> void:
	slider = get_parent() as Slider
	assert(slider != null, SLIDER_WARNING)

	if slider is VSlider:
		vertical = true

	var err = slider.connect("value_changed", self, "update_with_discard")
	assert(err == OK)

	if visibility_rule == VisibilityRule.ALWAYS:
		show()
	else:
		hide()

		match visibility_rule:
			VisibilityRule.ON_CLICK:
				err = slider.connect("gui_input", self, "_on_slider_gui_input")
				assert(err == OK)
			VisibilityRule.ON_HOVER:
				err = slider.connect("mouse_entered", self, "_on_slider_hover_focus", [true])
				assert(err == OK)
				err = slider.connect("mouse_exited", self, "_on_slider_hover_focus", [false])
				assert(err == OK)
			VisibilityRule.ON_FOCUS:
				err = slider.connect("focus_entered", self, "_on_slider_hover_focus", [true])
				assert(err == OK)
				err = slider.connect("focus_exited", self, "_on_slider_hover_focus", [false])
				assert(err == OK)

	update_label()


func _on_slider_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		visible = mouse_event.pressed
		update_label()


func _on_slider_hover_focus(hover: bool):
	visible = hover
	update_label()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		update_configuration_warning()


func update_with_discard(_discard):
	update_label()


func update_label():
	if not is_visible_in_tree():
		return

	text = str(slider.value)

	var grabber_size := slider.get_icon("Grabber").get_size()
	if vertical:
		rect_position.y = (
			(1.0 - slider.ratio) * (slider.rect_size.y - grabber_size.y)
			+ grabber_size.y * 0.5
			- rect_size.y * 0.5
		)
		if placement == Placement.TOP_RIGHT:
			rect_position.x = slider.rect_size.x + separation
		else:
			rect_position.x = -rect_size.x - separation
	else:
		rect_position.x = (
			slider.ratio * (slider.rect_size.x - grabber_size.x)
			+ grabber_size.x * 0.5
			- rect_size.x * 0.5
		)
		if placement == Placement.TOP_RIGHT:
			rect_position.y = -rect_size.y - separation
		else:
			rect_position.y = slider.rect_size.y + separation
