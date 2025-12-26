extends "res://tests/support/test_harness.gd"
# gdlint: disable=private-method-call

const ENEMY_VISUALS_SCRIPT := preload("res://src/enemy/enemy_visuals.gd")


func test_enemy_walk_animation_triggers_when_enemy_moves() -> void:
	var data := await _spawn_enemy_with_dependencies()
	var enemy: Node3D = data["enemy"]
	var visuals: Node3D = enemy.get_node("Visuals")
	visuals.set_script(ENEMY_VISUALS_SCRIPT)
	var sprite: AnimatedSprite2D = visuals.get_node("SpriteViewport/DogSprite")
	var initial_position: Vector3 = enemy.global_position
	enemy.global_position = initial_position + Vector3(1, 0, 0)
	tick_physics(visuals)
	assert_eq("walk", sprite.animation, "Enemy sprite must play walk animation while moving")


func test_enemy_visuals_script_attached_in_scene() -> void:
	var data := await _spawn_enemy_with_dependencies()
	var enemy: Node3D = data["enemy"]
	var visuals: Node3D = enemy.get_node("Visuals")
	var assigned_script: Script = visuals.get_script()
	assert_not_null(assigned_script, "Visuals node must have an attached script")
	assert_eq(ENEMY_VISUALS_SCRIPT, assigned_script, "Enemy Visuals must use enemy_visuals.gd")


func test_enemy_plays_alert_and_investigate_animations_by_state() -> void:
	var data := await _spawn_enemy_with_dependencies()
	var enemy: Node3D = data["enemy"]
	var visuals: Node3D = enemy.get_node("Visuals")
	var sprite: AnimatedSprite2D = visuals.get_node("SpriteViewport/DogSprite")
	enemy.set_physics_process(false)

	enemy._change_state(enemy.STATE_ALERT)
	tick_physics(visuals)
	assert_eq(
		GameConstants.ANIM_ALERT,
		sprite.animation,
		"Enemy sprite must play alert animation while in ALERT state"
	)

	enemy._change_state(enemy.STATE_INVESTIGATE)
	tick_physics(visuals)
	assert_eq(
		GameConstants.ANIM_INVESTIGATE,
		sprite.animation,
		"Enemy sprite must play investigate animation while investigating"
	)


func test_enemy_sprite_flips_when_direction_changes() -> void:
	var data := await _spawn_enemy_with_dependencies()
	var enemy: Node3D = data["enemy"]
	var visuals: Node3D = enemy.get_node("Visuals")
	var sprite: AnimatedSprite2D = visuals.get_node("SpriteViewport/DogSprite")
	enemy.set_physics_process(false)

	var origin: Vector3 = enemy.global_position
	enemy.global_position = origin + Vector3(1, 0, 0)
	tick_physics(visuals)
	assert_false(sprite.flip_h, "Enemy sprite should face right when moving right")

	enemy.global_position = origin + Vector3(-1, 0, 0)
	tick_physics(visuals)
	assert_true(sprite.flip_h, "Enemy sprite should flip horizontally when moving left")


func _spawn_enemy_with_dependencies() -> Dictionary:
	var player := instance_player(true)
	player.name = "Player"
	var waypoints := _create_waypoints()
	var overrides := {
		"player_path": NodePath("../Player"),
		"waypoint_a_path": NodePath("../Waypoints/WaypointA"),
		"waypoint_b_path": NodePath("../Waypoints/WaypointB"),
	}
	var enemy := await spawn_scene(ENEMY_SCENE_PATH, overrides) as Node3D
	return {"enemy": enemy, "player": player, "waypoints": waypoints}


func _create_waypoints() -> Node3D:
	var waypoints := Node3D.new()
	waypoints.name = "Waypoints"
	var waypoint_a := Node3D.new()
	waypoint_a.name = "WaypointA"
	var waypoint_b := Node3D.new()
	waypoint_b.name = "WaypointB"
	waypoints.add_child(waypoint_a)
	waypoints.add_child(waypoint_b)
	attach_node(waypoints)
	return waypoints
