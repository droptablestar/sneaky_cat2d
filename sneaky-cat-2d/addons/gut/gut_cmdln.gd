extends SceneTree

const GutClass := preload("res://addons/gut/gut.gd")

var _gut: Gut = null

func _initialize() -> void:
	_gut = GutClass.new()
	_gut.set_scene_tree(self)
	for dir_path in _collect_dirs():
		_gut.add_directory(dir_path)
	call_deferred("_run_tests")

func _run_tests() -> void:
	if _gut == null:
		push_error("GUT: Runner not initialized")
		quit(1)
		return
	var exit_code: int = _gut.run()
	quit(exit_code)

func _collect_dirs() -> Array[String]:
	var dirs: Array[String] = []
	var args: PackedStringArray = OS.get_cmdline_args()
	var index: int = 0
	while index < args.size():
		var arg: String = args[index]
		if arg == "--gut-dir" and index + 1 < args.size():
			dirs.append(args[index + 1])
			index += 2
			continue
		if arg.begins_with("--gut-dir="):
			var parts: PackedStringArray = arg.split("=", true, 1)
			if parts.size() == 2:
				dirs.append(parts[1])
			index += 1
			continue
		index += 1
	if dirs.is_empty():
		dirs.append("res://tests")
	return dirs
