## Follow camera
##
## Smoothly follows a target node (typically the player) with configurable offsets.
## Uses lerp for smooth camera movement rather than instant position updates.
extends Camera3D

## Path to the node this camera should follow (usually the player)
@export_node_path("Node3D") var target_path: NodePath

## Horizontal offset from target (positive = right)
@export var horizontal_offset: float = 0.0

## Vertical offset from target (positive = up)
@export var vertical_offset: float = 2.5

## Fixed Z position for camera (distance from 2.5D plane)
@export var camera_z: float = 8.0

## How quickly camera follows target (higher = snappier)
@export var follow_speed: float = 6.0

## Reference to the target node being followed
var _target: Node3D


func _ready() -> void:
	current = true  # Make this the active camera
	_target = _resolve_target()


func _process(delta: float) -> void:
	# Retry resolving target if it wasn't found initially
	if not _target:
		_target = _resolve_target()
		return

	# Calculate desired camera position based on target + offsets
	var desired: Vector3 = Vector3(
		_target.global_position.x + horizontal_offset,
		_target.global_position.y + vertical_offset,
		camera_z
	)

	# Smoothly interpolate to desired position
	var weight: float = clampf(delta * follow_speed, 0.0, 1.0)
	global_position = global_position.lerp(desired, weight)


## Resolves the target node from the exported path
func _resolve_target() -> Node3D:
	if target_path.is_empty():
		return null
	return get_node_or_null(target_path)
