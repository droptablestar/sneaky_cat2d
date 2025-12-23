## Hide spot area
##
## Defines an area where the player can hide to avoid enemy detection.
## Uses duck typing to call register/unregister methods on bodies that enter the area.
extends Area3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


## Called when a body enters the hide spot area.
## Registers this hide spot with the body if it has the register_hide_spot method (typically the player).
func _on_body_entered(body: Node) -> void:
	if body.has_method("register_hide_spot"):
		body.register_hide_spot(self)


## Called when a body exits the hide spot area.
## Unregisters this hide spot and forces the body to exit hiding.
func _on_body_exited(body: Node) -> void:
	if body.has_method("unregister_hide_spot"):
		body.unregister_hide_spot(self)
