extends CharacterBody2D

@export var move_speed: float = 240.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 1200.0


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	# Deterministic keyboard movement (no InputMap dependency).
	var axis := 0.0
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		axis -= 1.0
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		axis += 1.0
	velocity.x = axis * move_speed

	# Deterministic jump (no InputMap dependency).
	if is_on_floor() and (Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ENTER)):
		velocity.y = jump_velocity

	move_and_slide()
