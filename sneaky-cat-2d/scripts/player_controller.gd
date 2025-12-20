extends CharacterBody3D

@export var move_speed: float = 6.0
@export var jump_velocity: float = 8.0
@export var constrain_z: bool = true
@export var plane_z: float = 0.0

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	if constrain_z:
		plane_z = global_position.z

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta

	var axis_input := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = axis_input * move_speed
	velocity.z = 0.0

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()

	if constrain_z:
		global_position.z = plane_z
