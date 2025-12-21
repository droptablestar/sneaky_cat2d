extends "res://tests/support/test_harness.gd"

var default_gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func test_gravity_applies_when_airborne() -> void:
	var player := instance_player(true)
	assert_not_null(player, "Player scene should instantiate")
	assert_false(player.is_on_floor(), "No floor attached so player should be airborne")
	var previous_velocity := player.velocity.y
	var delta := 0.1
	player._physics_process(delta)
	var expected: float = previous_velocity - default_gravity * delta
	assert_true(
		is_equal_approx(player.velocity.y, expected),
		"Gravity should decrease Y velocity while airborne"
	)


func test_jump_does_not_fire_in_air() -> void:
	var player := instance_player(true)
	assert_not_null(player)
	assert_false(player.is_on_floor())
	player.velocity.y = player.jump_velocity
	player._physics_process(1.0 / 60.0)
	assert_true(
		player.velocity.y < player.jump_velocity,
		"Airborne attempt should still lose velocity due to gravity"
	)


func test_jump_applies_when_on_floor() -> void:
	var player := instance_player(true)
	assert_not_null(player)
	add_flat_floor()
	player.global_position = Vector3(0, 1.5, 0)
	step_physics(player, 30)
	assert_true(player.is_on_floor(), "Player must be on floor before jumping")
	player.floor_snap_length = 0.0
	var start_height: float = player.global_position.y
	player.velocity.y = player.jump_velocity
	player._physics_process(1.0 / 60.0)
	step_physics(player, 5)
	assert_false(player.is_on_floor(), "Player should leave the floor after jumping")
	assert_true(
		player.global_position.y > start_height, "Player should move upward right after jumping"
	)


func test_horizontal_axis_controls_velocity() -> void:
	var player := instance_player(true)
	assert_not_null(player)
	press_action("ui_right")
	player._physics_process(1.0 / 60.0)
	release_action("ui_right")
	assert_true(
		is_equal_approx(player.velocity.x, player.move_speed),
		"Pressing ui_right should move player right"
	)
	press_action("ui_left")
	player._physics_process(1.0 / 60.0)
	release_action("ui_left")
	assert_true(
		is_equal_approx(player.velocity.x, -player.move_speed),
		"Pressing ui_left should move player left"
	)


func test_z_plane_constraint_holds_position() -> void:
	var player := instance_player(true)
	assert_not_null(player)
	var plane_z: float = player.plane_z
	player.global_position.z = plane_z + 1.0
	player._physics_process(1.0 / 60.0)
	assert_true(
		is_equal_approx(player.global_position.z, plane_z),
		"Player should be constrained to initial Z plane"
	)
