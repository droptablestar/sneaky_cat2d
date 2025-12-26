extends "res://tests/support/test_harness.gd"


func test_hidden_state_freezes_velocity() -> void:
	var player := instance_player(true)
	assert_not_null(player)
	player.velocity = Vector3(3, 2, 0)
	player.call("_set_hidden", true)  # gdlint: disable=private-method-call
	assert_eq(Vector3.ZERO, player.velocity, "Velocity should reset immediately when hiding")
	press_action("ui_right")
	tick_physics(player)
	release_action("ui_right")
	assert_eq(
		Vector3.ZERO, player.velocity, "Hidden player should not accumulate movement velocity"
	)


func test_hidden_label_updates_visibility() -> void:
	var player := instance_player(true)
	assert_not_null(player)
	var label: Label3D = player.hidden_label
	player.call("_set_hidden", true)  # gdlint: disable=private-method-call
	assert_true(label.visible, "Hidden indicator must be visible when hidden")
	assert_eq("HIDDEN", label.text, "Hidden indicator text should read HIDDEN")
	player.call("_set_hidden", false)  # gdlint: disable=private-method-call
	assert_false(label.visible, "Indicator must hide once player leaves hiding")
