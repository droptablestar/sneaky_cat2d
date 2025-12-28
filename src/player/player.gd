extends CharacterBody2D

@export var move_speed: float = 240.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 1200.0


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	var axis := Input.get_axis("ui_left", "ui_right")
	velocity.x = axis * move_speed

	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_velocity

	move_and_slide()
