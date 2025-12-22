extends "res://addons/gut/test_case.gd"
class_name TestHarness

const PLAYER_SCENE_PATH := "res://scenes/player.tscn"
const ENEMY_SCENE_PATH := "res://scenes/enemy_patroller.tscn"
var _instanced_nodes: Array[Node] = []
var _attached_nodes: Array[Node] = []
var _world_root: Node3D = null
var _scene_tree_cache: SceneTree = null


func _gut_attach(gut: Object, scene_tree: SceneTree) -> void:
	super._gut_attach(gut, scene_tree)
	_scene_tree_cache = scene_tree


func before_each() -> void:
	_instanced_nodes.clear()
	_attached_nodes.clear()
	_clear_input_state()


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
	if add_to_tree:
		attach_node(instance)
	return instance


func instance_player(add_to_tree: bool = false) -> CharacterBody3D:
	var player := instantiate_scene(PLAYER_SCENE_PATH, false) as CharacterBody3D
	if add_to_tree and player != null:
		attach_node(player)
	return player


func instance_enemy(add_to_tree: bool = false) -> Node3D:
	var enemy := instantiate_scene(ENEMY_SCENE_PATH, false) as Node3D
	if add_to_tree and enemy != null:
		attach_node(enemy)
	return enemy


func add_flat_floor(y: float = 0.0, size: Vector3 = Vector3(20, 1, 4)) -> StaticBody3D:
	var floor := StaticBody3D.new()
	floor.position = Vector3(0, y, 0)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	collision.position = Vector3(0, size.y * 0.5, 0)
	floor.add_child(collision)
	_register_attached_node(floor)
	return floor


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
	_emit_input_event(action_name, true, strength)


func release_action(action_name: String) -> void:
	Input.action_release(action_name)
	_emit_input_event(action_name, false, 0.0)


func attach_node(node: Node) -> void:
	_register_attached_node(node)


func _register_attached_node(node: Node) -> void:
	var tree := _active_tree()
	if tree == null:
		fail("SceneTree is not available for attaching nodes")
		return
	_scene_tree_cache = tree
	_add_to_world(node)
	_attached_nodes.append(node)
	assert_true(node.is_inside_tree(), "Node failed to enter SceneTree")


func _clear_input_state() -> void:
	var actions := ["ui_left", "ui_right", "ui_accept", "hide_toggle"]
	for action in actions:
		Input.action_release(action)


func _emit_input_event(action_name: String, pressed: bool, strength: float) -> void:
	var event := InputEventAction.new()
	event.action = StringName(action_name)
	event.pressed = pressed
	event.strength = strength
	Input.parse_input_event(event)
	if Input.has_method("flush_buffered_events"):
		Input.flush_buffered_events()
	if action_name == "ui_accept":
		var key_event := InputEventKey.new()
		key_event.physical_keycode = Key.KEY_SPACE
		key_event.pressed = pressed
		Input.parse_input_event(key_event)
		if Input.has_method("flush_buffered_events"):
			Input.flush_buffered_events()


func _add_to_world(node: Node) -> void:
	var world_root := _ensure_world_root()
	if world_root == null:
		return
	if not world_root.is_inside_tree():
		fail("World root is not inside the SceneTree")
		return
	world_root.add_child(node)


func _ensure_world_root() -> Node3D:
	var tree := _active_tree()
	if tree == null:
		return null
	if _world_root == null or not is_instance_valid(_world_root):
		_world_root = Node3D.new()
		_world_root.name = "TestWorld"
		tree.root.add_child(_world_root)
	return _world_root


func _active_tree() -> SceneTree:
	if _scene_tree_cache != null and is_instance_valid(_scene_tree_cache):
		return _scene_tree_cache
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null:
		_scene_tree_cache = tree
	return _scene_tree_cache
