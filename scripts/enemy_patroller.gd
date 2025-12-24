## Enemy patroller AI
##
## Implements a three-state AI system for enemy behavior:
## - PATROL: Move between two waypoints
## - ALERT: Player spotted, tracking and filling detection meter
## - INVESTIGATE: Player lost, move to last known position
##
## Detection is vision cone-based with gradual meter filling. When the detection
## meter reaches 100, the level restarts.
extends Node3D

## Emitted when detection meter value changes (for HUD updates)
signal detection_meter_changed(value: float)

# Movement and detection settings
## Movement speed during patrol and investigation
@export var patrol_speed: float = 2.5

## Maximum distance the enemy can see the player
@export var detection_distance: float = 10.0

## Half-angle of the vision cone in degrees (45 = 90-degree total cone)
@export var cone_half_angle_deg: float = 45.0

## Rate at which detection meter fills per second when player is visible
@export var detection_fill_rate: float = 40.0

## Rate at which detection meter decays per second when player not visible
@export var detection_decay_rate: float = 25.0

## Grace period (seconds) after spotting player before detection starts filling
@export var alert_grace_time: float = 0.4

## How long (seconds) to pause at investigation point before returning to patrol
@export var investigate_pause_time: float = 2.0

## Fixed Z position for 2.5D plane constraint (set automatically in _ready)
@export var plane_z: float = 0.0

# Node path exports
## Path to first patrol waypoint
@export_node_path("Node3D") var waypoint_a_path: NodePath

## Path to second patrol waypoint
@export_node_path("Node3D") var waypoint_b_path: NodePath

## Path to player node
@export_node_path("Node3D") var player_path: NodePath

# State machine constants
const STATE_PATROL := "PATROL"  ## Patrolling between waypoints
const STATE_ALERT := "ALERT"  ## Player spotted, actively tracking
const STATE_INVESTIGATE := "INVESTIGATE"  ## Lost sight, investigating last position

# Public state
## Current detection meter value (0-100). Exposed for HUD access.
var detection_meter: float = 0.0

# Private state
var _waypoint_a: Node3D  ## Reference to first waypoint
var _waypoint_b: Node3D  ## Reference to second waypoint
var _player: Node3D  ## Reference to player
var _current_target: Node3D  ## Current waypoint being moved toward
var _facing: Vector3 = Vector3(1, 0, 0)  ## Direction enemy is facing (for vision cone)
var _current_state: String = STATE_PATROL  ## Current AI state
var _caught: bool = false  ## Whether player has been caught (prevents multiple restarts)
var _initial_y: float = 0.0  ## Y position to maintain (for 2.5D plane)
var _alert_timer: float = 0.0  ## Time spent in alert state (for grace period)
var _last_seen_position: Vector3 = Vector3.ZERO  ## Last position player was seen
var _investigate_destination: Vector3 = Vector3.ZERO  ## Target position when investigating
var _investigate_pause_timer: float = 0.0  ## Timer for pause at investigation point
var _investigate_moving: bool = false  ## Whether currently moving to investigation point

## 3D label showing current state (for debugging)
@onready var state_label: Label3D = $StateLabel


func _ready() -> void:
	# Add to enemy group for HUD to find
	if not is_in_group("enemy"):
		add_to_group("enemy")

	# Store initial position for plane constraint
	_initial_y = global_position.y
	plane_z = global_position.z

	# Resolve node paths
	_player = get_node_or_null(player_path)
	_waypoint_a = get_node_or_null(waypoint_a_path)
	_waypoint_b = get_node_or_null(waypoint_b_path)

	# Set initial patrol target
	if _waypoint_b:
		_current_target = _waypoint_b
	else:
		_current_target = _waypoint_a

	state_label.text = _current_state


## Main AI update loop - runs state machine and updates detection
func _physics_process(delta: float) -> void:
	var sees_player: bool = _check_player_visibility()

	# State machine - handle current state and transitions
	match _current_state:
		STATE_PATROL:
			_update_patrol(delta)
			if sees_player:
				_start_alert()
		STATE_ALERT:
			_update_alert_state(delta, sees_player)
		STATE_INVESTIGATE:
			_update_investigate_state(delta)
			if sees_player:
				_start_alert()

	_update_detection_meter(delta, sees_player)
	_check_caught()


## PATROL state: Move between waypoints
func _update_patrol(delta: float) -> void:
	if not _waypoint_a or not _waypoint_b or not _current_target:
		return

	# Get target position clamped to 2.5D plane
	var target_position: Vector3 = PositionUtils.clamp_to_plane(
		_current_target.global_position, _initial_y, plane_z
	)

	var to_target: Vector3 = target_position - global_position
	var distance: float = to_target.length()

	# Switch waypoints when close enough
	if distance < GameConstants.POSITION_SNAP_THRESHOLD:
		_switch_target()
		return

	# Move toward current waypoint
	var move_distance: float = min(distance, patrol_speed * delta)
	var direction: Vector3 = to_target.normalized()
	global_position += direction * move_distance
	PositionUtils.apply_plane_clamping(self, _initial_y, plane_z)

	# Update facing direction (for vision cone)
	if abs(direction.x) > GameConstants.VELOCITY_FLIP_THRESHOLD:
		if direction.x > 0.0:
			_facing = Vector3(1, 0, 0)
		else:
			_facing = Vector3(-1, 0, 0)


## Switches between waypoint A and waypoint B
func _switch_target() -> void:
	if _current_target == _waypoint_a:
		_current_target = _waypoint_b
	else:
		_current_target = _waypoint_a


## Checks if player is currently visible to this enemy.
## Player must be: not hidden, within detection distance, and in vision cone.
func _check_player_visibility() -> bool:
	if not _player or _player.is_hidden:
		return false

	var planar_distance: float = _get_planar_distance_to_player()
	if planar_distance == 0.0 or planar_distance > detection_distance:
		return false

	return _is_player_in_view_cone()


## Calculates planar distance to player (ignoring Y difference)
func _get_planar_distance_to_player() -> float:
	var to_player: Vector3 = _player.global_position - global_position
	var planar_offset: Vector3 = Vector3(to_player.x, 0, to_player.z)
	return planar_offset.length()


## Checks if player is within the enemy's vision cone
func _is_player_in_view_cone() -> bool:
	var to_player: Vector3 = _player.global_position - global_position
	var planar_offset: Vector3 = Vector3(to_player.x, 0, to_player.z)
	var to_player_dir: Vector3 = planar_offset.normalized()

	var facing: Vector3 = _facing.normalized()
	if facing.length() == 0.0:
		facing = Vector3(1, 0, 0)

	# Calculate angle between facing direction and player direction
	var dot: float = clamp(facing.dot(to_player_dir), -1.0, 1.0)
	var angle: float = rad_to_deg(acos(dot))

	return angle <= cone_half_angle_deg


## Updates the detection meter based on visibility and state.
## Fills when in ALERT state after grace period, decays otherwise.
func _update_detection_meter(delta: float, sees_player: bool) -> void:
	var should_fill: bool = (
		_current_state == STATE_ALERT and sees_player and _alert_timer >= alert_grace_time
	)
	if should_fill:
		detection_meter = min(
			GameConstants.DETECTION_METER_MAX, detection_meter + detection_fill_rate * delta
		)
	else:
		detection_meter = max(0.0, detection_meter - detection_decay_rate * delta)

	detection_meter_changed.emit(detection_meter)


## Checks if player has been caught (meter reached max).
## Restarts the level when caught.
func _check_caught() -> void:
	if _caught:
		return
	if detection_meter >= GameConstants.DETECTION_METER_MAX:
		_caught = true
		print("Enemy caught you! Restarting level...")
		get_tree().reload_current_scene()


## Transitions to ALERT state when player is spotted
func _start_alert() -> void:
	_alert_timer = 0.0
	_record_last_seen_position()
	_change_state(STATE_ALERT)


## ALERT state: Track player and update last seen position
func _update_alert_state(delta: float, sees_player: bool) -> void:
	if sees_player:
		_alert_timer += delta
		_record_last_seen_position()
	else:
		# Lost sight of player - start investigating
		_start_investigation()


## Transitions to INVESTIGATE state
func _start_investigation() -> void:
	_alert_timer = 0.0
	if _last_seen_position == Vector3.ZERO:
		_record_last_seen_position()
	_investigate_destination = Vector3(_last_seen_position.x, _initial_y, plane_z)
	_investigate_moving = true
	_investigate_pause_timer = 0.0
	_change_state(STATE_INVESTIGATE)


## INVESTIGATE state: Move to last known position, pause, then return to patrol
func _update_investigate_state(delta: float) -> void:
	if _investigate_moving:
		_move_to_investigate_destination(delta)
	else:
		_investigate_pause_timer += delta
		if _investigate_pause_timer >= investigate_pause_time:
			_return_to_patrol()


## Moves toward investigation destination
func _move_to_investigate_destination(delta: float) -> void:
	var to_dest: Vector3 = _investigate_destination - global_position
	var distance_x: float = abs(to_dest.x)

	if distance_x < GameConstants.POSITION_SNAP_THRESHOLD:
		_snap_to_destination()
	else:
		_advance_toward_destination(to_dest, distance_x, delta)

	PositionUtils.apply_plane_clamping(self, _initial_y, plane_z)


## Snaps to investigation destination and starts pause timer
func _snap_to_destination() -> void:
	global_position.x = _investigate_destination.x
	_investigate_moving = false
	_investigate_pause_timer = 0.0


## Advances toward investigation destination
func _advance_toward_destination(to_dest: Vector3, distance_x: float, delta: float) -> void:
	var direction_sign: float = 1.0 if to_dest.x >= 0.0 else -1.0
	var move_distance: float = min(distance_x, patrol_speed * delta)
	global_position.x += direction_sign * move_distance
	_facing = Vector3(direction_sign, 0, 0)


## Returns to PATROL state, choosing nearest waypoint as target
func _return_to_patrol() -> void:
	_investigate_moving = false
	_investigate_pause_timer = 0.0
	_choose_next_patrol_target()
	_change_state(STATE_PATROL)


## Chooses the waypoint farthest from current position as next target
func _choose_next_patrol_target() -> void:
	if not _waypoint_a or not _waypoint_b:
		return
	var distance_to_a: float = abs(global_position.x - _waypoint_a.global_position.x)
	var distance_to_b: float = abs(global_position.x - _waypoint_b.global_position.x)
	if distance_to_a < distance_to_b:
		_current_target = _waypoint_b
	else:
		_current_target = _waypoint_a


## Records the player's current position (clamped to 2.5D plane)
func _record_last_seen_position() -> void:
	if not _player:
		return
	_last_seen_position = PositionUtils.clamp_to_plane(_player.global_position, _initial_y, plane_z)


## Changes the current AI state and updates debug label
func _change_state(new_state: String) -> void:
	if _current_state == new_state:
		return
	_current_state = new_state
	state_label.text = new_state
	print("Enemy state ->", new_state)


## Returns current detection meter value (for HUD access)
func get_detection_meter() -> float:
	return detection_meter


## Get the state of the enemy
func get_state() -> String:
	return _current_state
