class_name Utils
extends Reference


# attempts to format a reference in a human-readable way
# - `reference`, `Reference`: the reference to print
static func pprint(reference: Reference) -> void:
	match reference.get_class():
		"Dictionary", "Array":
			print(JSON.print(reference, "  "))
		_:
			print(reference)
