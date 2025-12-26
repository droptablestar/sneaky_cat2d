## Position utility functions for 2.5D plane constraint
##
## Provides static utility functions for clamping positions to specific Y and Z planes.
## Used throughout the game to maintain the 2.5D side-scrolling constraint.
class_name PositionUtils


## Clamps a Vector3 position to specified Y and Z planes.
##
## Useful for ensuring positions stay within the 2.5D gameplay plane.
##
## Parameters:
##   position: The position to clamp
##   y_plane: The Y coordinate to clamp to
##   z_plane: The Z coordinate to clamp to
##
## Returns: A new Vector3 with Y and Z clamped to specified planes, X unchanged
static func clamp_to_plane(position: Vector3, y_plane: float, z_plane: float) -> Vector3:
	var clamped := position
	clamped.y = y_plane
	clamped.z = z_plane
	return clamped


## Applies planar clamping to a node's global position.
##
## Convenience function that clamps a Node3D's global_position in-place.
##
## Parameters:
##   node: The Node3D whose position should be clamped
##   y_plane: The Y coordinate to clamp to
##   z_plane: The Z coordinate to clamp to
static func apply_plane_clamping(node: Node3D, y_plane: float, z_plane: float) -> void:
	node.global_position = clamp_to_plane(node.global_position, y_plane, z_plane)
