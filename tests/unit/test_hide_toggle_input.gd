extends "res://tests/support/test_harness.gd"


func _read_project_godot_text() -> String:
	var f := FileAccess.open("res://project.godot", FileAccess.READ)
	assert_not_null(f, "Failed to open res://project.godot")
	return f.get_as_text()


func _extract_input_action_block(text: String, action: String) -> String:
	var start := text.find(action + "={")
	assert_true(start != -1, "project.godot must contain %s action" % action)

	var i := start
	var depth := 0
	var began := false
	while i < text.length():
		var c := text[i]
		if c == "{":
			depth += 1
			began = true
		elif c == "}":
			depth -= 1
			if began and depth == 0:
				return text.substr(start, i - start + 1)
		i += 1

	return text.substr(start, min(2000, text.length() - start))


func _block_has_f_key_binding(block: String) -> bool:
	# Headless serialization for this project may store the binding as:
	# - key_label: 70 and/or unicode: 102 ('f')
	# and may leave keycode/physical_keycode at 0.
	# Accept any of these as "F is bound".
	var re := RegEx.new()
	var pattern := '(physical_keycode|keycode|key_label)"?:\\s*70\\b|unicode"?:\\s*102\\b'
	var err := re.compile(pattern)
	assert_eq(err, OK, "Failed to compile regex for key binding check")

	return re.search(block) != null


func test_project_has_hide_toggle_bound_to_f_in_project_file() -> void:
	assert_true(InputMap.has_action("hide_toggle"), "InputMap must define hide_toggle action")

	var text := _read_project_godot_text()
	var block := _extract_input_action_block(text, "hide_toggle")

	var message := (
		(
			"project.godot hide_toggle must reference F (via key_label/keycode/physical_keycode=70"
			+ " or unicode=102).\nBlock was:\n%s"
		)
		% block
	)
	assert_true(_block_has_f_key_binding(block), message)


func test_hide_state_transitions_and_unhide_on_exit_emit_signal() -> void:
	var player := instance_player(true)
	assert_not_null(player)

	var emitted: Array[bool] = []
	player.hidden_state_changed.connect(func(is_hidden: bool) -> void: emitted.append(is_hidden))

	var spot := Node3D.new()
	player.register_hide_spot(spot)

	player.call("_set_hidden", true)
	assert_true(player.is_hidden, "Player should become hidden when set hidden")
	assert_eq(1, emitted.size(), "hidden_state_changed should emit once on hide")
	assert_eq(true, emitted[0], "First hidden_state_changed should be true")

	player.unregister_hide_spot(spot)
	spot.free()

	assert_false(player.is_hidden, "Player should unhide when leaving hide spot")
	assert_eq(2, emitted.size(), "hidden_state_changed should emit again on unhide")
	assert_eq(false, emitted[1], "Second hidden_state_changed should be false")
