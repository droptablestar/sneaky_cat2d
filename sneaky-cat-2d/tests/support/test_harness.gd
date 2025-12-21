extends GutTest
class_name TestHarness

var _instanced_nodes: Array[Node] = []
var _attached_nodes: Array[Node] = []

func before_each() -> void:
	_instanced_nodes.clear()
	_attached_nodes.clear()

func after_each() -> void:
	for node in _attached_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.queue_free()
	for node in _instanced_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() == null:
			node.free()
	_instanced_nodes.clear()
	_attached_nodes.clear()

func instantiate_scene(path: String, add_to_tree: bool = false) -> Node:
	var resource: Resource = load(path)
	var packed: PackedScene = resource as PackedScene
	if packed == null:
		fail("Could not load PackedScene from %s" % path)
		return null
	var instance: Node = packed.instantiate()
	_instanced_nodes.append(instance)
	if add_to_tree and get_scene_tree() != null:
		get_scene_tree().root.add_child(instance)
		_attached_nodes.append(instance)
	return instance

func step_physics(target: Node, steps: int, delta: float = 1.0 / 60.0) -> void:
	if target == null:
		fail("step_physics target cannot be null")
		return
	for _i in range(steps):
		_call_physics_recursive(target, delta)

func _call_physics_recursive(node: Node, delta: float) -> void:
	if node.has_method("_physics_process"):
		node._physics_process(delta)
	for child in node.get_children():
		var child_node: Node = child as Node
		if child_node != null:
			_call_physics_recursive(child_node, delta)

func press_action(action_name: String, strength: float = 1.0) -> void:
	Input.action_press(action_name, strength)

func release_action(action_name: String) -> void:
	Input.action_release(action_name)
