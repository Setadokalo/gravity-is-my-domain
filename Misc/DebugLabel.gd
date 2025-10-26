extends Label

@export var target: Node
@export var property: String

@export var override_target: String

func _process(_delta: float) -> void:
	if not target and override_target.is_empty():
		return
	var eff_target := target
	if not target and has_node(override_target):
		eff_target = get_node(override_target)
	elif not target:
		return
	if property.ends_with(")"):
		var start_of_args := property.find("(")
		var args = property.substr(start_of_args + 1, property.length() - start_of_args - 2).split(",", false)
		# if args.size() == 1 and args[0] == "":
		# 	args.clear()
		text = str(eff_target.callv(property.substr(0, start_of_args), args))
	elif eff_target.get(property):
		text = str(eff_target.get(property))
