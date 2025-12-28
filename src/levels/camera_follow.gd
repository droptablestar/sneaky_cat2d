## Camera follow helper (Godot 4.x)
##
## Follows a target on X while keeping Y fixed so the floor framing stays stable.
extends Camera2D

@export_node_path("Node2D") var target_path: NodePath
@export var fixed_y: float = 360.0

var _target: Node2D = null


func _ready() -> void:
	if target_path != NodePath():
		_target = get_node_or_null(target_path) as Node2D


func _process(_delta: float) -> void:
	if _target == null:
		return
	global_position = Vector2(_target.global_position.x, fixed_y)
