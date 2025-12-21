extends Node3D

@export var patrol_speed: float = 2.5
@export var detection_distance: float = 10.0
@export var cone_half_angle_deg: float = 45.0
@export var detection_fill_rate: float = 40.0
@export var detection_decay_rate: float = 25.0
@export var alert_grace_time: float = 0.4
@export var investigate_pause_time: float = 2.0
@export var plane_z: float = 0.0

@export_node_path("Node3D") var waypoint_a_path: NodePath
@export_node_path("Node3D") var waypoint_b_path: NodePath
@export_node_path("Node3D") var player_path: NodePath

var velocity: Vector3 = Vector3.ZERO
var _last_pos: Vector3

const STATE_PATROL := "PATROL"
const STATE_ALERT := "ALERT"
const STATE_INVESTIGATE := "INVESTIGATE"

var detection_meter: float = 0.0
var _waypoint_a: Node3D
var _waypoint_b: Node3D
var _player: Node3D
var _current_target: Node3D
var _facing: Vector3 = Vector3(1, 0, 0)
var _current_state: String = STATE_PATROL
var _last_bucket: int = -25
var _caught: bool = false
var _initial_y: float = 0.0
var _alert_timer: float = 0.0
var _last_seen_position: Vector3 = Vector3.ZERO
var _investigate_destination: Vector3 = Vector3.ZERO
var _investigate_pause_timer: float = 0.0
var _investigate_moving: bool = false

@onready var state_label: Label3D = $StateLabel


func _ready() -> void:
	if not is_in_group("enemy"):
		add_to_group("enemy")
	_initial_y = global_position.y
	plane_z = global_position.z
	_player = get_node_or_null(player_path)
	_waypoint_a = get_node_or_null(waypoint_a_path)
	_waypoint_b = get_node_or_null(waypoint_b_path)
	if _waypoint_b:
		_current_target = _waypoint_b
	else:
		_current_target = _waypoint_a
	state_label.text = _current_state
	_last_pos = global_position


func _physics_process(delta: float) -> void:
	var sees_player: bool = _check_player_visibility()

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

	velocity = (global_position - _last_pos) / max(delta, 0.0001)
	_last_pos = global_position


func _update_patrol(delta: float) -> void:
	if not _waypoint_a or not _waypoint_b or not _current_target:
		return

	var target_position: Vector3 = _current_target.global_position
	target_position.y = _initial_y
	target_position.z = plane_z

	var to_target: Vector3 = target_position - global_position
	var distance: float = to_target.length()

	if distance < 0.05:
		_switch_target()
		return

	var move_distance: float = min(distance, patrol_speed * delta)
	var direction: Vector3 = to_target.normalized()
	global_position += direction * move_distance
	global_position.y = _initial_y
	global_position.z = plane_z

	if abs(direction.x) > 0.01:
		if direction.x > 0.0:
			_facing = Vector3(1, 0, 0)
		else:
			_facing = Vector3(-1, 0, 0)


func _switch_target() -> void:
	if _current_target == _waypoint_a:
		_current_target = _waypoint_b
	else:
		_current_target = _waypoint_a


func _check_player_visibility() -> bool:
	if not _player:
		return false
	if _player.is_hidden:
		return false

	var to_player: Vector3 = _player.global_position - global_position
	var planar_offset: Vector3 = Vector3(to_player.x, 0, to_player.z)
	var distance: float = planar_offset.length()
	if distance == 0.0 or distance > detection_distance:
		return false

	var facing: Vector3 = _facing.normalized()
	if facing.length() == 0.0:
		facing = Vector3(1, 0, 0)
	var to_player_dir: Vector3 = planar_offset.normalized()
	var dot: float = clamp(facing.dot(to_player_dir), -1.0, 1.0)
	var angle: float = rad_to_deg(acos(dot))
	if angle > cone_half_angle_deg:
		return false

	return true


func _update_detection_meter(delta: float, sees_player: bool) -> void:
	var should_fill: bool = (
		_current_state == STATE_ALERT and sees_player and _alert_timer >= alert_grace_time
	)
	if should_fill:
		detection_meter = min(100.0, detection_meter + detection_fill_rate * delta)
	else:
		detection_meter = max(0.0, detection_meter - detection_decay_rate * delta)

	var current_bucket: int = int(floor(detection_meter / 25.0)) * 25
	if current_bucket != _last_bucket:
		_last_bucket = current_bucket
		if current_bucket > 0:
			print("Detection meter:", current_bucket)
		elif detection_meter == 0.0:
			print("Detection meter reset")


func _check_caught() -> void:
	if _caught:
		return
	if detection_meter >= 100.0:
		_caught = true
		print("Enemy caught you! Restarting level...")
		get_tree().reload_current_scene()


func _start_alert() -> void:
	_alert_timer = 0.0
	_record_last_seen_position()
	_change_state(STATE_ALERT)


func _update_alert_state(delta: float, sees_player: bool) -> void:
	if sees_player:
		_alert_timer += delta
		_record_last_seen_position()
	else:
		_start_investigation()


func _start_investigation() -> void:
	_alert_timer = 0.0
	if _last_seen_position == Vector3.ZERO:
		_record_last_seen_position()
	_investigate_destination = Vector3(_last_seen_position.x, _initial_y, plane_z)
	_investigate_moving = true
	_investigate_pause_timer = 0.0
	_change_state(STATE_INVESTIGATE)


func _update_investigate_state(delta: float) -> void:
	if _investigate_moving:
		var to_dest: Vector3 = _investigate_destination - global_position
		var distance_x: float = abs(to_dest.x)
		if distance_x < 0.05:
			global_position.x = _investigate_destination.x
			_investigate_moving = false
			_investigate_pause_timer = 0.0
		else:
			var direction_sign: float = 1.0
			if to_dest.x < 0.0:
				direction_sign = -1.0
			var move_distance: float = min(distance_x, patrol_speed * delta)
			global_position.x += direction_sign * move_distance
			_facing = Vector3(direction_sign, 0, 0)
		global_position.y = _initial_y
		global_position.z = plane_z
	else:
		_investigate_pause_timer += delta
		if _investigate_pause_timer >= investigate_pause_time:
			_return_to_patrol()


func _return_to_patrol() -> void:
	_investigate_moving = false
	_investigate_pause_timer = 0.0
	_choose_next_patrol_target()
	_change_state(STATE_PATROL)


func _choose_next_patrol_target() -> void:
	if not _waypoint_a or not _waypoint_b:
		return
	var distance_to_a: float = abs(global_position.x - _waypoint_a.global_position.x)
	var distance_to_b: float = abs(global_position.x - _waypoint_b.global_position.x)
	if distance_to_a < distance_to_b:
		_current_target = _waypoint_b
	else:
		_current_target = _waypoint_a


func _record_last_seen_position() -> void:
	if not _player:
		return
	_last_seen_position = _player.global_position
	_last_seen_position.y = _initial_y
	_last_seen_position.z = plane_z


func _change_state(new_state: String) -> void:
	if _current_state == new_state:
		return
	_current_state = new_state
	state_label.text = new_state
	print("Enemy state ->", new_state)


func get_detection_meter() -> float:
	return detection_meter
