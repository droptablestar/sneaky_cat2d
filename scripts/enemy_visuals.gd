extends Node3D

@export var walk_threshold: float = 0.05

@onready var _enemy: Node3D = get_parent()
@onready var _sprite: AnimatedSprite2D = $SpriteViewport/DogSprite

var _current_animation: String = ""
var _last_pos: Vector3 = Vector3.ZERO

func _ready() -> void:
	_current_animation = "walk"
	if not _enemy or not _sprite:
		return
	_last_pos = _enemy.global_position
	_sprite.play(_current_animation)

func _physics_process(_delta: float) -> void:
	if not _enemy or not _sprite:
		return
	var delta_pos: Vector3 = _enemy.global_position - _last_pos
	var speed: float = delta_pos.length()
	_last_pos = _enemy.global_position

	var target := "idle"
	if speed > walk_threshold:
		target = "walk"

	if target != _current_animation:
		_current_animation = target
		_sprite.play(_current_animation)
