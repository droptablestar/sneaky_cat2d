extends Node3D

@export var walk_threshold: float = 0.1

@onready var _player: CharacterBody3D = get_parent() as CharacterBody3D
@onready var _sprite: AnimatedSprite2D = $SpriteViewport/CatSprite

var _current_animation: String = ""

func _ready() -> void:
    if _sprite:
        _sprite.play("idle")
        _current_animation = "idle"

func _physics_process(_delta: float) -> void:
    if not _player or not _sprite:
        return
    var target_animation: String = "idle"
    if _player.is_hidden:
        target_animation = "hidden"
    elif absf(_player.velocity.x) > walk_threshold:
        target_animation = "walk"

    if target_animation != _current_animation:
        _current_animation = target_animation
        _sprite.play(_current_animation)

    if absf(_player.velocity.x) > 0.01:
        _sprite.flip_h = _player.velocity.x < 0.0
