extends Node3D

@export var walk_threshold: float = 0.1

@onready var _player: CharacterBody3D = get_parent() as CharacterBody3D
@onready var _sprite: AnimatedSprite2D = $SpriteViewport/CatSprite

var _current_animation: String = ""

func _ready() -> void:
	if _sprite:
		_sprite.play("idle")
		_current_animation = "idle"
	_dump_sprite_nodes()

func _physics_process(_delta: float) -> void:
	if not _player or not _sprite:
		return
	var target_animation: String = "idle"
	if _player.is_hidden:
		target_animation = "hidden"
	elif not _player.is_on_floor():
		target_animation = "jump"
	elif absf(_player.velocity.x) > walk_threshold:
		target_animation = "walk"

	if target_animation != _current_animation:
		_current_animation = target_animation
		_sprite.play(_current_animation)

	if absf(_player.velocity.x) > 0.01:
		_sprite.flip_h = _player.velocity.x < 0.0

func _dump_sprite_nodes() -> void:
	var player := get_parent()
	print("--- Sprite dump under Player ---")
	for n in player.find_children("*", "Node", true, false):
		if n is Sprite3D or n is AnimatedSprite3D or n is Sprite2D or n is AnimatedSprite2D:
			print(n.get_path(), "  type=", n.get_class(), "  visible=", n.visible)
	print("-------------------------------")
