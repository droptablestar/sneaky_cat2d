extends Camera3D

@export_node_path("Node3D") var target_path: NodePath
@export var horizontal_offset: float = 0.0
@export var vertical_offset: float = 2.5
@export var camera_z: float = 8.0
@export var follow_speed: float = 6.0

var _target: Node3D


func _ready() -> void:
	current = true
	_target = _resolve_target()


func _process(delta: float) -> void:
	if not _target:
		_target = _resolve_target()
		return

	var desired: Vector3 = Vector3(
		_target.global_position.x + horizontal_offset,
		_target.global_position.y + vertical_offset,
		camera_z
	)

	var weight: float = clampf(delta * follow_speed, 0.0, 1.0)
	global_position = global_position.lerp(desired, weight)


func _resolve_target() -> Node3D:
	if target_path.is_empty():
		return null
	return get_node_or_null(target_path)
