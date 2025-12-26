extends "res://tests/support/test_harness.gd"

const TICK_DELTA := 1.0 / 60.0


func test_visuals_play_hidden_when_player_hidden() -> void:
	var data := _setup_player_with_visuals(true)
	var player: CharacterBody3D = data["player"]
	var visuals: BaseCharacterVisuals = data["visuals"]
	var sprite: AnimatedSprite2D = data["sprite"]
	player.is_hidden = true
	player.velocity = Vector3.ZERO
	visuals.tick(TICK_DELTA)
	assert_eq("hidden", sprite.animation, "Hidden animation should play when player is hidden")


func test_visuals_play_walk_when_velocity_exceeds_threshold() -> void:
	var data := _setup_player_with_visuals(true)
	var player: CharacterBody3D = data["player"]
	var visuals: BaseCharacterVisuals = data["visuals"]
	var sprite: AnimatedSprite2D = data["sprite"]
	player.is_hidden = false
	player.velocity = Vector3(visuals.walk_threshold + 0.2, 0, 0)
	visuals.tick(TICK_DELTA)
	assert_eq("walk", sprite.animation, "Walk animation should play when moving on the floor")


func test_visuals_play_idle_when_not_moving() -> void:
	var data := _setup_player_with_visuals(true)
	var player: CharacterBody3D = data["player"]
	var visuals: BaseCharacterVisuals = data["visuals"]
	var sprite: AnimatedSprite2D = data["sprite"]
	player.is_hidden = false
	player.velocity = Vector3.ZERO
	visuals.tick(TICK_DELTA)
	assert_eq("idle", sprite.animation, "Idle animation should play when stationary on the floor")


func test_visuals_play_jump_when_airborne() -> void:
	var data := _setup_player_with_visuals(false)
	var player: CharacterBody3D = data["player"]
	var visuals: BaseCharacterVisuals = data["visuals"]
	var sprite: AnimatedSprite2D = data["sprite"]
	player.is_hidden = false
	player.velocity = Vector3(0.1, 0, 0)
	visuals.tick(TICK_DELTA)
	assert_eq("jump", sprite.animation, "Jump animation should play when not on floor")


func test_visuals_flip_matches_velocity_direction() -> void:
	var data := _setup_player_with_visuals(true)
	var player: CharacterBody3D = data["player"]
	var visuals: BaseCharacterVisuals = data["visuals"]
	var sprite: AnimatedSprite2D = data["sprite"]
	player.is_hidden = false
	player.velocity = Vector3(0.5, 0, 0)
	visuals.tick(TICK_DELTA)
	assert_false(sprite.flip_h, "Sprite should face right for positive velocity.x")
	player.velocity = Vector3(-0.5, 0, 0)
	visuals.tick(TICK_DELTA)
	assert_true(sprite.flip_h, "Sprite should face left for negative velocity.x")


func test_cat_sprite_frames_include_required_animations() -> void:
	var player := instance_player(false)
	assert_not_null(player)
	var sprite: AnimatedSprite2D = player.get_node("Visuals/SpriteViewport/CatSprite")
	var frames: SpriteFrames = sprite.sprite_frames
	var required := ["idle", "walk", "hidden", "jump"]
	for animation_name in required:
		assert_true(
			frames.has_animation(animation_name),
			"Cat sprite frames missing %s animation" % animation_name
		)


func _setup_player_with_visuals(on_floor: bool) -> Dictionary:
	var player := instance_player(true)
	var visuals: BaseCharacterVisuals = player.get_node("Visuals")
	var sprite: AnimatedSprite2D = visuals.get_node("SpriteViewport/CatSprite")
	if on_floor:
		add_flat_floor()
		player.global_position = Vector3(0, 1.5, 0)
		step_physics(player, 30)
		assert_true(player.is_on_floor(), "Player should be on floor for this test")
	else:
		player.global_position = Vector3(0, 2.5, 0)
		player.velocity = Vector3.ZERO
		tick_physics(player)
		assert_false(player.is_on_floor(), "Player should be airborne for this test")
	return {"player": player, "visuals": visuals, "sprite": sprite}
