extends CharacterBody2D

const NORMAL_SIZE: Vector2 = Vector2(32, 48)
const NORMAL_OFFSET_TOP: float = -24.0
const NORMAL_COLOR: Color = Color(1, 1, 1, 1)
const HIDDEN_SIZE: Vector2 = Vector2(32, 32)
const HIDDEN_OFFSET_TOP: float = -10.0
const HIDDEN_COLOR: Color = Color(0.8, 0.8, 0.8, 1)
const HIDE_TABLE_SCRIPT: Script = preload("res://src/furniture/hide_table.gd")

@export var move_speed: float = 240.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 1200.0
@export var hidden_move_speed: float = 100.0

@onready var anim: AnimatedSprite2D = $Anim

var is_hiding: bool = false
var overlapping_hide_zones: Array[Area2D] = []
var f_key_was_pressed: bool = false
var active_hideable: Node = null

@onready var detection_area: Area2D = $DetectionArea


func _ready() -> void:
	detection_area.area_entered.connect(_on_area_entered)
	detection_area.area_exited.connect(_on_area_exited)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle hide toggle with F key (edge detection to prevent repeated toggles)
	var f_key_is_pressed: bool = Input.is_key_pressed(KEY_F)
	if f_key_is_pressed and not f_key_was_pressed:
		_try_toggle_hide()
	f_key_was_pressed = f_key_is_pressed

	# Determine active move speed based on hide state
	var active_move_speed: float = hidden_move_speed if is_hiding else move_speed

	# Deterministic keyboard movement (no InputMap dependency).
	var axis := 0.0
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		axis -= 1.0
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		axis += 1.0
	velocity.x = axis * active_move_speed

	# Deterministic jump (no InputMap dependency). Disabled when hiding.
	var jump_pressed: bool = (
		Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ENTER)
	)
	if not is_hiding and is_on_floor() and jump_pressed:
		velocity.y = jump_velocity

	move_and_slide()
	_update_visuals()


func _on_area_entered(area: Area2D) -> void:
	# Check if this is a hide zone by checking parent node type
	var parent: Node = area.get_parent()
	if parent and parent.get_script() == HIDE_TABLE_SCRIPT:
		overlapping_hide_zones.append(area)


func _on_area_exited(area: Area2D) -> void:
	var index: int = overlapping_hide_zones.find(area)
	if index != -1:
		overlapping_hide_zones.remove_at(index)
		# If we exit the zone we're hiding in, force unhide
		if is_hiding and overlapping_hide_zones.is_empty():
			_exit_hide_mode()


func _try_toggle_hide() -> void:
	if is_hiding:
		_exit_hide_mode()
	elif not overlapping_hide_zones.is_empty():
		_enter_hide_mode()


func _enter_hide_mode() -> void:
	anim.position.y += HIDDEN_OFFSET_TOP
	is_hiding = true

	# pick the hideable node we’re hiding under
	active_hideable = overlapping_hide_zones[0].get_parent()
	if active_hideable and active_hideable.has_method("set_occluding"):
		active_hideable.call("set_occluding", true)


func _exit_hide_mode() -> void:
	is_hiding = false
	anim.position.y -= HIDDEN_OFFSET_TOP

	if active_hideable and active_hideable.has_method("set_occluding"):
		active_hideable.call("set_occluding", false)
	active_hideable = null

func _update_visuals() -> void:
	if not is_instance_valid(anim):
		return
	if anim.sprite_frames == null:
		return

	var moving: bool = abs(velocity.x) > 0.01 or abs(velocity.y) > 0.01

	# Flip based on horizontal motion only (visual-only)
	if abs(velocity.x) > 0.01:
		anim.flip_h = velocity.x < 0.0

	# Play/stop only if the animation exists (won’t error before you set it up)
	if is_hiding:
		if anim.sprite_frames.has_animation("hide"):
			if anim.animation != "hide":
				anim.animation = "hide"
			if not anim.is_playing():
				anim.play()
	elif moving:
		if anim.sprite_frames.has_animation("walk"):
			if anim.animation != "walk":
				anim.animation = "walk"
			if not anim.is_playing():
				anim.play()
	else:
		if anim.sprite_frames.has_animation("idle"):
			if anim.animation != "idle":
				anim.animation = "idle"
			if not anim.is_playing():
				anim.play()
		else:
			anim.stop()
