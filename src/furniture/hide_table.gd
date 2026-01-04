extends Node2D
## A table that the player can hide under.
## The HideZone Area2D child detects when the player is in range.

# === Table Geometry Constants ===
const TABLE_WIDTH: float = 120.0
const TABLE_HEIGHT: float = 20.0
const TABLE_TOP_Y: float = -10.0

const LEG_WIDTH: float = 10.0
const LEG_HEIGHT: float = 40.0
const LEG_TOP_Y: float = 10.0
const LEG_BOTTOM_Y: float = 50.0
const LEG_LEFT_X: float = -50.0
const LEG_RIGHT_X: float = 40.0

const HIDEZONE_WIDTH: float = 100.0
const HIDEZONE_HEIGHT: float = 60.0
const HIDEZONE_POS_Y: float = 0.0

const TABLETOP_COLLISION_WIDTH: float = 110.0
const TABLETOP_COLLISION_HEIGHT: float = 4.0
const TABLETOP_COLLISION_POS_Y: float = -8.0

const TABLE_Y_SORT_ORIGIN: float = 50.0

@onready var front_occluder: CanvasItem = $FrontOccluder
@onready var table_visual: ColorRect = $Back/TableVisual
@onready var leg_visual_1: ColorRect = $Back/LegVisual1
@onready var leg_visual_2: ColorRect = $Back/LegVisual2
@onready var hide_zone: Area2D = $HideZone
@onready var hide_zone_shape: CollisionShape2D = $HideZone/CollisionShape2D
@onready var tabletop: StaticBody2D = $Tabletop
@onready var tabletop_shape: CollisionShape2D = $Tabletop/CollisionShape2D


func _ready() -> void:
	# Apply layout from constants
	# Note: y_sort_enabled and y_sort_origin are set in HideTable.tscn

	# Table top (both front occluder and back visual)
	var half_width: float = TABLE_WIDTH / 2.0
	var half_height: float = TABLE_HEIGHT / 2.0
	front_occluder.offset_left = -half_width
	front_occluder.offset_top = TABLE_TOP_Y
	front_occluder.offset_right = half_width
	front_occluder.offset_bottom = TABLE_TOP_Y + TABLE_HEIGHT
	front_occluder.visible = false

	table_visual.offset_left = -half_width
	table_visual.offset_top = TABLE_TOP_Y
	table_visual.offset_right = half_width
	table_visual.offset_bottom = TABLE_TOP_Y + TABLE_HEIGHT

	# Legs
	leg_visual_1.offset_left = LEG_LEFT_X
	leg_visual_1.offset_top = LEG_TOP_Y
	leg_visual_1.offset_right = LEG_LEFT_X + LEG_WIDTH
	leg_visual_1.offset_bottom = LEG_BOTTOM_Y

	leg_visual_2.offset_left = LEG_RIGHT_X
	leg_visual_2.offset_top = LEG_TOP_Y
	leg_visual_2.offset_right = LEG_RIGHT_X + LEG_WIDTH
	leg_visual_2.offset_bottom = LEG_BOTTOM_Y

	# HideZone Area2D
	hide_zone.position.y = HIDEZONE_POS_Y
	var hide_rect_shape: RectangleShape2D = hide_zone_shape.shape as RectangleShape2D
	if hide_rect_shape:
		hide_rect_shape.size = Vector2(HIDEZONE_WIDTH, HIDEZONE_HEIGHT)

	# Tabletop collision (one-way platform)
	tabletop.position.y = TABLETOP_COLLISION_POS_Y
	var tabletop_rect_shape: RectangleShape2D = tabletop_shape.shape as RectangleShape2D
	if tabletop_rect_shape:
		tabletop_rect_shape.size = Vector2(TABLETOP_COLLISION_WIDTH, TABLETOP_COLLISION_HEIGHT)


func set_occluding(is_occluding: bool) -> void:
	if front_occluder:
		front_occluder.visible = is_occluding
