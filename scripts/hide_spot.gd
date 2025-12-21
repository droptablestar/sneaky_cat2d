extends Area3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body.has_method("register_hide_spot"):
		body.register_hide_spot(self)


func _on_body_exited(body: Node) -> void:
	if body.has_method("unregister_hide_spot"):
		body.unregister_hide_spot(self)
