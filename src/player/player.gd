extends CharacterBody2D

const NORMAL_SIZE: Vector2 = Vector2(32, 48)
const NORMAL_OFFSET_TOP: float = -24.0
const NORMAL_COLOR: Color = Color(1, 1, 1, 1)
const HIDDEN_SIZE: Vector2 = Vector2(32, 32)
const HIDDEN_OFFSET_TOP: float = -16.0
const HIDDEN_COLOR: Color = Color(0.8, 0.8, 0.8, 1)
const HIDE_TABLE_SCRIPT: Script = preload("res://src/furniture/hide_table.gd")

@export var move_speed: float = 240.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 1200.0
@export var hidden_move_speed: float = 100.0

var is_hiding: bool = false
var overlapping_hide_zones: Array[Area2D] = []
var f_key_was_pressed: bool = false

@onready var visual: ColorRect = $Visual
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
	is_hiding = true
	visual.size = HIDDEN_SIZE
	visual.offset_top = HIDDEN_OFFSET_TOP
	visual.offset_bottom = HIDDEN_OFFSET_TOP + HIDDEN_SIZE.y
	visual.color = HIDDEN_COLOR


func _exit_hide_mode() -> void:
	is_hiding = false
	visual.size = NORMAL_SIZE
	visual.offset_top = NORMAL_OFFSET_TOP
	visual.offset_bottom = NORMAL_OFFSET_TOP + NORMAL_SIZE.y
	visual.color = NORMAL_COLOR
