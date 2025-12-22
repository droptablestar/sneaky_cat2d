extends CharacterBody3D

@export var move_speed: float = 6.0
@export var jump_velocity: float = 8.0
@export var constrain_z: bool = true
@export var plane_z: float = 0.0

var is_hidden: bool = false
var _current_hide_spot: Node3D = null
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var hidden_label: Label3D = $HiddenIndicator


func _ready() -> void:
	if constrain_z:
		plane_z = global_position.z
	hidden_label.visible = false
	hidden_label.text = ""


func _physics_process(delta: float) -> void:
	_handle_hide_input()

	if is_hidden:
		velocity = Vector3.ZERO
	else:
		if not is_on_floor():
			velocity.y -= _gravity * delta

		var axis_input: float = (
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		)
		velocity.x = axis_input * move_speed
		velocity.z = 0.0

		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = jump_velocity

	move_and_slide()

	if constrain_z:
		global_position.z = plane_z


func register_hide_spot(spot: Node3D) -> void:
	_current_hide_spot = spot


func unregister_hide_spot(spot: Node3D) -> void:
	if _current_hide_spot == spot:
		_current_hide_spot = null
		_set_hidden(false)


func _handle_hide_input() -> void:
	if not _current_hide_spot:
		return
	if Input.is_action_just_pressed("hide_toggle"):
		_set_hidden(not is_hidden)


func _set_hidden(hidden: bool) -> void:
	if is_hidden == hidden:
		return
	is_hidden = hidden
	if hidden:
		velocity = Vector3.ZERO
	hidden_label.visible = hidden
	hidden_label.text = "HIDDEN" if hidden else ""
