extends Node2D

@export var wall_color: Color = Color(0.22, 0.22, 0.22, 1.0)
@export var floor_color: Color = Color(0.30, 0.25, 0.20, 1.0)
@export var wallpaper_modulate: Color = Color(1, 1, 1, 1)
@export var wallpaper_offset: Vector2 = Vector2(0, 360)
@export var wallpaper_scale: Vector2 = Vector2(1280, 720)

func _ready():
    $Wall.color = wall_color
    $FloorVisual.color = floor_color
    $Wallpaper.modulate = wallpaper_modulate
    $Wallpaper.position = wallpaper_offset
    $Wallpaper.scale = wallpaper_scale
