extends RefCounted
class_name Gut

const TEST_PREFIX := "test_"
const TEST_CASE_CLASS := preload("res://addons/gut/test_case.gd")

var _dirs: Array[String] = []
var _scene_tree: SceneTree = null
var tests_run: int = 0
var assertions: int = 0
var failures: Array[Dictionary] = []
var _current_case_name: String = ""
var _current_test_name: String = ""

const TEST_HARNESS := preload("res://tests/support/test_harness.gd")


func set_scene_tree(tree: SceneTree) -> void:
	_scene_tree = tree


func add_directory(path: String) -> void:
	if path.is_empty():
		return
	if path in _dirs:
		return
	_dirs.append(path)


func run() -> int:
	var case_scripts: Array[Script] = _collect_case_scripts()
	if case_scripts.is_empty():
		push_warning("GUT: No tests discovered. Did you create files under res://tests?")
	for script_ref: Script in case_scripts:
		if script_ref == null or not script_ref.can_instantiate():
			continue
		var instance: Variant = script_ref.new()
		var case_node: Node = instance as Node
		if case_node == null:
			continue
		case_node._gut_attach(self, _scene_tree)
		if _scene_tree != null:
			_scene_tree.root.add_child(case_node)
		case_node._gut_run()
		if is_instance_valid(case_node):
			if case_node.get_parent() != null:
				case_node.get_parent().remove_child(case_node)
			case_node.free()
	_print_summary()
	return 0 if failures.is_empty() else 1


func _collect_case_scripts() -> Array[Script]:
	var scripts: Array[Script] = []
	for dir_path: String in _dirs:
		_collect_from_dir(dir_path, scripts)
	return scripts


func _collect_from_dir(path: String, scripts: Array[Script]) -> void:
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		push_warning("GUT: Unable to read directory %s" % path)
		return
	dir.list_dir_begin()
	while true:
		var entry: String = dir.get_next()
		if entry == "":
			break
		if dir.current_is_dir():
			if entry.begins_with("."):
				continue
			_collect_from_dir(path.path_join(entry), scripts)
			continue
		if not entry.ends_with(".gd"):
			continue
		var script_path: String = path.path_join(entry)
		var resource: Resource = load(script_path)
		var script_ref: Script = resource as Script
		if script_ref == null:
			continue
		if script_ref == null or not script_ref.can_instantiate():
			continue
		var instance: Variant = script_ref.new()
		var case_node: Node = instance as Node
		if case_node != null:
			scripts.append(script_ref)
		if is_instance_valid(case_node):
			case_node.free()
	dir.list_dir_end()


func _print_summary() -> void:
	print(
		"[GUT] Tests: %d  Assertions: %d  Failures: %d" % [tests_run, assertions, failures.size()]
	)
	for failure in failures:
		var data: Dictionary = failure
		print(
			(
				"[GUT][FAIL] %s > %s :: %s"
				% [data.get("case", ""), data.get("test", ""), data.get("message", "")]
			)
		)


func _start_test(case_name: String, test_name: String) -> void:
	_current_case_name = case_name
	_current_test_name = test_name
	tests_run += 1
	print("[GUT] RUN %s > %s" % [case_name, test_name])


func _finish_test() -> void:
	_current_case_name = ""
	_current_test_name = ""


func _record_assertion(passed: bool, message: String) -> void:
	assertions += 1
	if passed:
		return
	var failure: Dictionary = {
		"case": _current_case_name, "test": _current_test_name, "message": message
	}
	failures.append(failure)
