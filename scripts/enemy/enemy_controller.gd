## Enemy patroller controller
##
## Orchestrates sensing, AI decision, movement application, and visuals. The AI
## state machine lives in scripts/enemy/enemy_ai.gd and returns an intent each
## tick; this controller applies that intent and remains the sole physics owner.
extends Node3D

## Emitted when detection meter value changes (for HUD updates)
signal detection_meter_changed(value: float)

# Movement and detection settings
@export var patrol_speed: float = 2.5
@export var detection_distance: float = 10.0
@export var cone_half_angle_deg: float = 45.0
@export var detection_fill_rate: float = 40.0
@export var detection_decay_rate: float = 25.0
@export var alert_grace_time: float = 0.4
@export var investigate_pause_time: float = 2.0
@export var plane_z: float = 0.0

# Node path exports
@export_node_path("Node3D") var waypoint_a_path: NodePath
@export_node_path("Node3D") var waypoint_b_path: NodePath
@export_node_path("Node3D") var player_path: NodePath

# Public state
var detection_meter: float = 0.0

# Private state
var _waypoint_a: Node3D
var _waypoint_b: Node3D
var _player: Node3D
var _caught: bool = false
var _initial_y: float = 0.0
var _ai: EnemyAI

@onready var state_label: Label3D = $StateLabel
@onready var _visuals: BaseCharacterVisuals = $Visuals


func _ready() -> void:
	# Add to enemy group for HUD to find
	if not is_in_group("enemy"):
		add_to_group("enemy")

	_initial_y = global_position.y
	plane_z = global_position.z

	_player = get_node_or_null(player_path)
	_waypoint_a = get_node_or_null(waypoint_a_path)
	_waypoint_b = get_node_or_null(waypoint_b_path)
	assert(state_label, "Enemy requires a StateLabel child.")
	assert(_player, "Enemy requires player_path to be assigned.")
	assert(_waypoint_a, "Enemy requires waypoint_a_path to be assigned.")
	assert(_waypoint_b, "Enemy requires waypoint_b_path to be assigned.")
	assert(_visuals, "Enemy requires a Visuals child.")

	_ai = EnemyAI.new()
	state_label.text = _ai.get_state()


func _physics_process(delta: float) -> void:
	_tick(delta)


func _tick(delta: float) -> void:
	var ctx: Dictionary = _build_ai_context(delta)
	var intent: Dictionary = _ai.tick(delta, ctx)
	_apply_intent(intent)

	if _visuals:
		_visuals.tick(delta, _ai.get_state())


func _build_ai_context(_delta: float) -> Dictionary:
	return {
		"position": global_position,
		"initial_y": _initial_y,
		"plane_z": plane_z,
		"patrol_speed": patrol_speed,
		"detection_distance": detection_distance,
		"cone_half_angle_deg": cone_half_angle_deg,
		"detection_fill_rate": detection_fill_rate,
		"detection_decay_rate": detection_decay_rate,
		"alert_grace_time": alert_grace_time,
		"investigate_pause_time": investigate_pause_time,
		"detection_meter": detection_meter,
		"player_position": _player.global_position if _player else null,
		"player_hidden": _player.is_hidden if _player else true,
		"waypoint_a": _waypoint_a.global_position if _waypoint_a else null,
		"waypoint_b": _waypoint_b.global_position if _waypoint_b else null,
	}


func _apply_intent(intent: Dictionary) -> void:
	var move_delta: Vector3 = intent.get("move_delta", Vector3.ZERO)
	global_position += move_delta
	PositionUtils.apply_plane_clamping(self, _initial_y, plane_z)

	var detection_delta: float = intent.get("detection_delta", 0.0)
	detection_meter = clamp(
		detection_meter + detection_delta, 0.0, GameConstants.DETECTION_METER_MAX
	)
	detection_meter_changed.emit(detection_meter)

	if intent.get("state_changed", false):
		var label_text: String = intent.get("state_label_text", state_label.text)
		state_label.text = label_text
		DebugUtils.dbg("Enemy state ->", label_text)

	if (
		not _caught
		and (
			intent.get("caught_player", false)
			or detection_meter >= GameConstants.DETECTION_METER_MAX
		)
	):
		_caught = true
		DebugUtils.dbg("Enemy caught you! Restarting level...")
		get_tree().reload_current_scene()


## Returns current detection meter value (for HUD access)
func get_detection_meter() -> float:
	return detection_meter


## Get the state of the enemy
func get_state() -> String:
	return _ai.get_state()
