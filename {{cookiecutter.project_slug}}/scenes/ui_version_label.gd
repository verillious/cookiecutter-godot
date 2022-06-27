class_name VersionLabel
extends Label


func _init() -> void:
	text = (
		"v%s" % ProjectSettings.get_setting("application/config/version")
		if ProjectSettings.has_setting("application/config/version")
		else "v1.0.0"
	)
