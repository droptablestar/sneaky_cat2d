## Player character controller
##
## Handles player movement, jumping, hiding, and physics in a 2.5D side-scroller.
## Movement is constrained to the X axis (horizontal), Y axis (jumping), with Z fixed.
extends CharacterBody3D

## Emitted when the player's hidden state changes
signal hidden_state_changed(is_hidden: bool)

## Horizontal movement speed
@export var move_speed: float = 6.0

## Upward velocity applied when jumping
@export var jump_velocity: float = 8.0

## Whether to constrain Z position (for 2.5D gameplay)
@export var constrain_z: bool = true

## Z-plane position to maintain (set automatically in _ready if constrain_z is true)
@export var plane_z: float = 0.0

## Whether the player is currently hidden. When true, player is invisible to enemies.
var is_hidden: bool = false

## Current hide spot the player is near (null if not near any hide spot)
var _current_hide_spot: Node3D = null

## Gravity value from project settings
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

## 3D label showing "HIDDEN" text above player when hiding
@onready var hidden_label: Label3D = $HiddenIndicator
## Visuals component (driven manually to keep a single physics owner)
@onready var _visuals: BaseCharacterVisuals = $Visuals


func _ready() -> void:
	# Add to player group for HUD to find
	if not is_in_group("player"):
		add_to_group("player")

	# Set up Z-plane constraint
	if constrain_z:
		plane_z = global_position.z
	hidden_label.visible = false


func _physics_process(delta: float) -> void:
	_handle_hide_input()

	if is_hidden:
		# Freeze movement while hidden
		velocity = Vector3.ZERO
	else:
		# Apply gravity when not on floor
		if not is_on_floor():
			velocity.y -= _gravity * delta

		# Handle horizontal movement (left/right arrow keys or ui_left/ui_right)
		var axis_input: float = (
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		)
		velocity.x = axis_input * move_speed
		velocity.z = 0.0  # No Z movement in 2.5D

		# Handle jumping (space key or ui_accept)
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = jump_velocity

	move_and_slide()

	# Maintain Z-plane constraint
	if constrain_z:
		global_position.z = plane_z

	if _visuals:
		_visuals.tick(delta)


## Called by HideSpot when player enters a hide area.
## Registers the hide spot so player can press F to hide.
func register_hide_spot(spot: Node3D) -> void:
	_current_hide_spot = spot


## Called by HideSpot when player exits a hide area.
## Unregisters the hide spot and forces player to exit hiding.
func unregister_hide_spot(spot: Node3D) -> void:
	if _current_hide_spot == spot:
		_current_hide_spot = null
		_set_hidden(false)


## Handles hide toggle input (F key).
## Only works when player is near a registered hide spot.
func _handle_hide_input() -> void:
	if not _current_hide_spot:
		return
	if Input.is_action_just_pressed("hide_toggle"):
		_set_hidden(not is_hidden)


## Sets the hidden state and updates UI.
## Emits hidden_state_changed signal for HUD updates.
func _set_hidden(hidden: bool) -> void:
	if is_hidden == hidden:
		return
	is_hidden = hidden
	if hidden:
		velocity = Vector3.ZERO  # Stop movement when hiding
	hidden_label.visible = hidden
	hidden_label.text = "HIDDEN" if hidden else ""
	hidden_state_changed.emit(is_hidden)
