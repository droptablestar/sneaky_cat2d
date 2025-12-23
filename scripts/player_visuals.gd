## Player visual animations
##
## Handles player sprite animations and flipping based on player state.
## Extends BaseCharacterVisuals to inherit common animation logic.
extends BaseCharacterVisuals


## Returns the player sprite node
func _resolve_sprite() -> AnimatedSprite2D:
	return $SpriteViewport/CatSprite


## Determines which animation should play based on player state
func _determine_target_animation() -> String:
	var player: CharacterBody3D = _parent_character as CharacterBody3D
	if not player:
		return GameConstants.ANIM_IDLE

	# Priority order: hidden > jump > walk > idle
	if player.is_hidden:
		return GameConstants.ANIM_HIDDEN
	elif not player.is_on_floor():
		return GameConstants.ANIM_JUMP
	elif absf(player.velocity.x) > walk_threshold:
		return GameConstants.ANIM_WALK

	return GameConstants.ANIM_IDLE


## Enables sprite flipping for player
func _should_flip_sprite() -> bool:
	return true


## Returns player velocity.x for determining flip direction
func _get_flip_direction() -> float:
	var player: CharacterBody3D = _parent_character as CharacterBody3D
	if not player:
		return 0.0
	return player.velocity.x
