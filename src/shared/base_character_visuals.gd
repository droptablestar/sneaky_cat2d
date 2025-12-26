## Base class for character visual animation management
##
## Handles sprite animation state machine and directional flipping for all characters.
## Subclasses should override the template methods to provide character-specific behavior.
##
## Usage:
##   1. Extend this class in your character visual script
##   2. Override _resolve_sprite() to return your sprite node
##   3. Override _determine_target_animation() to define animation state logic
##   4. Optionally override _should_flip_sprite() and _get_flip_direction() for flipping
##
## Example:
##   [codeblock]
##   extends BaseCharacterVisuals
##
##   func _resolve_sprite() -> AnimatedSprite2D:
##       return $SpriteViewport/MySprite
##
##   func _determine_target_animation() -> String:
##       if parent.is_moving:
##           return GameConstants.ANIM_WALK
##       return GameConstants.ANIM_IDLE
##   [/codeblock]
class_name BaseCharacterVisuals
extends Node3D

## Velocity threshold for triggering walk animation.
## Movement speed must exceed this value to be considered "walking".
@export var walk_threshold: float = 0.1

## Currently playing animation name
var _current_animation: String = ""

## Reference to the AnimatedSprite2D node for this character
var _sprite: AnimatedSprite2D = null

## Reference to the parent character controller
var _parent_character: Node3D = null


func _ready() -> void:
	init_visuals()


## Initializes parent/sprite wiring and starts initial animation.
func init_visuals() -> void:
	_parent_character = get_parent()
	_sprite = _resolve_sprite()
	_initialize_animation()


## Override this to return the sprite node path.
##
## Returns the AnimatedSprite2D node that should be animated.
## Subclasses must implement this to specify their sprite location.
##
## Returns: AnimatedSprite2D node or null if not found
func _resolve_sprite() -> AnimatedSprite2D:
	return null


## Override this to set the initial animation.
##
## Called during initialization to determine which animation should play first.
## Defaults to ANIM_IDLE but can be overridden for different starting states.
##
## Returns: String name of the initial animation to play
func _get_initial_animation() -> String:
	return GameConstants.ANIM_IDLE


## Initializes the animation system.
##
## Sets up the initial animation state and starts playing the first animation.
## Called automatically during _ready().
func _initialize_animation() -> void:
	if not _sprite:
		return
	var initial: String = _get_initial_animation()
	_sprite.play(initial)
	_current_animation = initial


## Updates animation and sprite flip each frame.
##
## Called by the owning controller to keep visuals in sync with movement/state.
## Optional state parameter lets controllers pass explicit state data to visuals.
func tick(_delta: float, state: Variant = null) -> void:
	if not _parent_character or not _sprite:
		return

	var target_animation: String = _determine_target_animation(state)
	_update_animation(target_animation)
	_update_sprite_flip()


## Override this to define animation state logic.
##
## This method should examine the parent character's state and return
## the appropriate animation name. Called each tick from the controller, with
## optional state data supplied by the controller.
##
## Example:
##   [codeblock]
##   func _determine_target_animation() -> String:
##       if player.is_hidden:
##           return GameConstants.ANIM_HIDDEN
##       elif not player.is_on_floor():
##           return GameConstants.ANIM_JUMP
##       elif absf(player.velocity.x) > walk_threshold:
##           return GameConstants.ANIM_WALK
##       return GameConstants.ANIM_IDLE
##   [/codeblock]
##
## Returns: String name of the animation that should currently play
func _determine_target_animation(_state: Variant = null) -> String:
	return GameConstants.ANIM_IDLE


## Override this to enable sprite flipping.
##
## Returns true if the sprite should flip based on movement direction.
## Defaults to false (no flipping).
##
## Returns: true if sprite should flip horizontally, false otherwise
func _should_flip_sprite() -> bool:
	return false


## Updates the sprite animation if it changed.
##
## Only changes the animation if the target differs from the current animation,
## preventing unnecessary animation restarts.
##
## Parameters:
##   target_animation: The animation name that should be playing
func _update_animation(target_animation: String) -> void:
	if target_animation != _current_animation:
		_current_animation = target_animation
		_sprite.play(_current_animation)


## Updates sprite horizontal flip based on movement direction.
##
## Only flips if _should_flip_sprite() returns true and the flip direction
## exceeds the velocity threshold. This prevents jittering during small movements.
func _update_sprite_flip() -> void:
	if _should_flip_sprite():
		var flip_direction: float = _get_flip_direction()
		if absf(flip_direction) > GameConstants.VELOCITY_FLIP_THRESHOLD:
			_sprite.flip_h = flip_direction < 0.0


## Override this to return the value used for flipping.
##
## Typically returns velocity.x from the parent character.
## Negative values flip the sprite left, positive values flip right.
##
## Returns: float value determining flip direction (e.g., velocity.x)
func _get_flip_direction() -> float:
	return 0.0
