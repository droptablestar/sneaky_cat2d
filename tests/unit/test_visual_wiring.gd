extends "res://tests/support/test_harness.gd"


func test_player_subviewport_pipeline_configured() -> void:
	var player := instance_player(false)
	assert_not_null(player)
	var visuals: Node3D = player.get_node("Visuals")
	var viewport: SubViewport = visuals.get_node("SpriteViewport")
	assert_true(viewport.size.x > 0 and viewport.size.y > 0, "Player sprite viewport must have non-zero size")
	var billboard: Sprite3D = visuals.get_node("BillboardSprite")
	var texture := billboard.texture as ViewportTexture
	assert_not_null(texture, "Billboard texture must be a ViewportTexture")
	assert_eq(NodePath("Visuals/SpriteViewport"), texture.viewport_path, "Viewport path should point to SpriteViewport")
	var resolved_viewport := player.get_node(texture.viewport_path) as SubViewport
	assert_not_null(resolved_viewport, "ViewportTexture path should resolve to an actual SubViewport")
	var sprite: AnimatedSprite2D = viewport.get_node("CatSprite")
	assert_not_null(sprite, "CatSprite node missing")
	assert_not_null(sprite.sprite_frames, "Cat sprite frames not assigned")

func test_enemy_subviewport_pipeline_configured() -> void:
	var enemy := instance_enemy(false)
	assert_not_null(enemy)
	var visuals: Node3D = enemy.get_node("Visuals")
	var viewport: SubViewport = visuals.get_node("SpriteViewport")
	assert_true(viewport.size.x > 0 and viewport.size.y > 0, "Enemy viewport must have non-zero size")
	var billboard: Sprite3D = visuals.get_node("BillboardSprite")
	var texture := billboard.texture as ViewportTexture
	assert_not_null(texture, "Enemy billboard texture must be a ViewportTexture")
	assert_eq(NodePath("Visuals/SpriteViewport"), texture.viewport_path, "Enemy viewport path mismatch")
	var resolved_viewport := enemy.get_node(texture.viewport_path) as SubViewport
	assert_not_null(resolved_viewport, "Enemy viewport path should resolve")
	var sprite: AnimatedSprite2D = viewport.get_node("DogSprite")
	assert_not_null(sprite, "DogSprite node missing")
	assert_not_null(sprite.sprite_frames, "Dog sprite frames not assigned")
	assert_true(sprite.sprite_frames.has_animation("walk"), "Dog sprite frames should define walk animation")
