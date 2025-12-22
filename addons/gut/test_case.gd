extends Node
class_name GutTest

var _gut: Object = null
var _scene_tree: SceneTree = null
var _current_test: String = ""


func _gut_attach(gut: Object, scene_tree: SceneTree) -> void:
	_gut = gut
	_scene_tree = scene_tree


func _gut_run() -> void:
	var methods: Array[String] = _get_test_methods()
	methods.sort()
	for method_name in methods:
		_current_test = method_name
		_gut._start_test(_get_case_name(), method_name)
		before_each()
		_run_single_test(method_name)
		after_each()
		_gut._finish_test()


func _get_case_name() -> String:
	var script_ref: Script = get_script()
	if script_ref == null or script_ref.resource_path.is_empty():
		return name
	return script_ref.resource_path


func _get_test_methods() -> Array[String]:
	var out: Array[String] = []
	var script_ref: GDScript = get_script() as GDScript
	if script_ref == null:
		return out
	for method_data in script_ref.get_script_method_list():
		var method_dict: Dictionary = method_data
		var method_name: String = method_dict.get("name", "")
		if method_name.begins_with("test_"):
			out.append(method_name)
	return out


func _run_single_test(method_name: String) -> void:
	var callable: Callable = Callable(self, method_name)
	if not callable.is_valid():
		_gut._record_assertion(false, "Missing test method '%s'" % method_name)
		return
	callable.call()


func before_each() -> void:
	pass


func after_each() -> void:
	pass


func get_scene_tree() -> SceneTree:
	return _scene_tree


func assert_true(value: bool, message: String = "") -> void:
	var final_message: String = message if message != "" else "Expected condition to be true."
	_gut._record_assertion(value, final_message)


func assert_false(value: bool, message: String = "") -> void:
	var final_message: String = message if message != "" else "Expected condition to be false."
	_gut._record_assertion(not value, final_message)


func assert_not_null(value: Variant, message: String = "") -> void:
	var final_message: String = message if message != "" else "Expected value to be assigned."
	_gut._record_assertion(value != null, final_message)


func assert_eq(expected: Variant, actual: Variant, message: String = "") -> void:
	var passed: bool = expected == actual
	var final_message: String = (
		message if message != "" else "Expected %s but got %s" % [expected, actual]
	)
	_gut._record_assertion(passed, final_message)


func fail(message: String) -> void:
	_gut._record_assertion(false, message)
