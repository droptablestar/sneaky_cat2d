@onready var cam := $Camera2D
@onready var player := $Player
func _ready() -> void:
	cam.reparent(player)
	cam.position = Vector2.ZERO
