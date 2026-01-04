extends Node2D
## A table that the player can hide under.
## The HideZone Area2D child detects when the player is in range.
@onready var front_occluder: CanvasItem = $FrontOccluder

func set_occluding(is_occluding: bool) -> void:
	if front_occluder:
		front_occluder.visible = is_occluding
