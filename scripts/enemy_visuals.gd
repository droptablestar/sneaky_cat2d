## Enemy visual animations
##
## Handles enemy sprite animations based on movement.
## Extends BaseCharacterVisuals to inherit common animation logic.
extends BaseCharacterVisuals

## Previous position for calculating movement speed
var _last_pos: Vector3 = Vector3.ZERO


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
		return GameConstants.ANIM_IDLE

	# Calculate movement speed by comparing position change
	var delta_pos: Vector3 = _parent_character.global_position - _last_pos
	var speed: float = delta_pos.length()
	_last_pos = _parent_character.global_position

	if speed > walk_threshold:
		return GameConstants.ANIM_WALK

	return GameConstants.ANIM_IDLE
