## Enemy visual animations
##
## Handles enemy sprite animations based on movement.
## Extends BaseCharacterVisuals to inherit common animation logic.
extends BaseCharacterVisuals

## Previous position for calculating movement speed and direction
var _last_pos: Vector3 = Vector3.ZERO
## Cached horizontal direction used for sprite flipping
var _last_horizontal_delta: float = 1.0


## Returns the enemy sprite node
func _resolve_sprite() -> AnimatedSprite2D:
	return $SpriteViewport/DogSprite


## Returns initial animation (enemies start walking)
func _get_initial_animation() -> String:
	return GameConstants.ANIM_WALK


func _ready() -> void:
	super._ready()
	if _parent_character:
		_last_pos = _parent_character.global_position


## Determines animation based on whether enemy is moving
func _determine_target_animation() -> String:
	if not _parent_character:
		return GameConstants.ANIM_WALK

	var delta_pos: Vector3 = _parent_character.global_position - _last_pos
	_last_pos = _parent_character.global_position
	_update_last_horizontal_delta(delta_pos.x)

	# Prefer AI state-driven animations.
	if _parent_character.has_method("get_state"):
		var state: String = _parent_character.get_state()
		if state == _parent_character.STATE_ALERT:
			return GameConstants.ANIM_ALERT
		if state == _parent_character.STATE_INVESTIGATE:
			return GameConstants.ANIM_INVESTIGATE

	# Calculate movement speed by comparing position change
	if delta_pos.length() > walk_threshold:
		return GameConstants.ANIM_WALK

	# Fall back to walk until we have a bespoke idle animation
	return GameConstants.ANIM_WALK


## Enables sprite flipping so the dog faces the direction of travel
func _should_flip_sprite() -> bool:
	return true


## Uses last horizontal movement delta to determine flip direction
func _get_flip_direction() -> float:
	return _last_horizontal_delta


func _update_last_horizontal_delta(delta_x: float) -> void:
	if absf(delta_x) > GameConstants.VELOCITY_FLIP_THRESHOLD:
		_last_horizontal_delta = delta_x
