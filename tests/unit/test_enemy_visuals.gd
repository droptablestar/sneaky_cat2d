extends "res://tests/support/test_harness.gd"

const ENEMY_VISUALS_SCRIPT := preload("res://scripts/enemy_visuals.gd")


func test_enemy_walk_animation_triggers_when_enemy_moves() -> void:
	var enemy := instance_enemy(false)
	assert_not_null(enemy)
	var visuals: Node3D = enemy.get_node("Visuals")
	visuals.set_script(ENEMY_VISUALS_SCRIPT)
	attach_node(enemy)
	var sprite: AnimatedSprite2D = visuals.get_node("SpriteViewport/DogSprite")
	var initial_position: Vector3 = enemy.global_position
	enemy.global_position = initial_position + Vector3(1, 0, 0)
	visuals._physics_process(1.0 / 60.0)
	assert_eq("walk", sprite.animation, "Enemy sprite must play walk animation while moving")


func test_enemy_visuals_script_attached_in_scene() -> void:
	var enemy := instance_enemy(false)
	assert_not_null(enemy)
	var visuals: Node3D = enemy.get_node("Visuals")
	var assigned_script: Script = visuals.get_script()
	assert_not_null(assigned_script, "Visuals node must have an attached script")
	assert_eq(ENEMY_VISUALS_SCRIPT, assigned_script, "Enemy Visuals must use enemy_visuals.gd")


func test_enemy_plays_alert_and_investigate_animations_by_state() -> void:
	var enemy := instance_enemy(true)
	assert_not_null(enemy)
	var visuals: Node3D = enemy.get_node("Visuals")
	var sprite: AnimatedSprite2D = visuals.get_node("SpriteViewport/DogSprite")
	enemy.set_physics_process(false)

	enemy._change_state(enemy.STATE_ALERT)
	visuals._physics_process(1.0 / 60.0)
	assert_eq(
		GameConstants.ANIM_ALERT,
		sprite.animation,
		"Enemy sprite must play alert animation while in ALERT state"
	)

	enemy._change_state(enemy.STATE_INVESTIGATE)
	visuals._physics_process(1.0 / 60.0)
	assert_eq(
		GameConstants.ANIM_INVESTIGATE,
		sprite.animation,
		"Enemy sprite must play investigate animation while investigating"
	)


func test_enemy_sprite_flips_when_direction_changes() -> void:
	var enemy := instance_enemy(true)
	assert_not_null(enemy)
	var visuals: Node3D = enemy.get_node("Visuals")
	var sprite: AnimatedSprite2D = visuals.get_node("SpriteViewport/DogSprite")
	enemy.set_physics_process(false)

	var origin: Vector3 = enemy.global_position
	enemy.global_position = origin + Vector3(1, 0, 0)
	visuals._physics_process(1.0 / 60.0)
	assert_false(sprite.flip_h, "Enemy sprite should face right when moving right")

	enemy.global_position = origin + Vector3(-1, 0, 0)
	visuals._physics_process(1.0 / 60.0)
	assert_true(sprite.flip_h, "Enemy sprite should flip horizontally when moving left")
