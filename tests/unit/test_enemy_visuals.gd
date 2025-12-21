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
