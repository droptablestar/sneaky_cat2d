extends TestHarness

func test_main_scene_contains_core_nodes() -> void:
	var scene: Node = instantiate_scene("res://main.tscn")
	assert_not_null(scene, "Main scene should instantiate")
	if scene == null:
		return
	var player: Node = scene.get_node_or_null("Player")
	assert_not_null(player, "Player node missing")
	var enemy: Node = scene.get_node_or_null("Level/Enemy")
	assert_not_null(enemy, "Enemy node missing")
	var hud: Node = scene.get_node_or_null("HUD")
	assert_not_null(hud, "HUD missing")
