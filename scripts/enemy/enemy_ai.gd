## Enemy AI component
##
## Encapsulates enemy state machine and intent generation. Consumes read-only
## context from the controller and returns an intent dict describing movement,
## state transitions, and detection adjustments. No scene-tree access here.
class_name EnemyAI
extends RefCounted

const STATE_PATROL := "PATROL"
const STATE_ALERT := "ALERT"
const STATE_INVESTIGATE := "INVESTIGATE"

var _current_state: String = STATE_PATROL
var _facing: Vector3 = Vector3(1, 0, 0)
var _alert_timer: float = 0.0
var _last_seen_position: Vector3 = Vector3.ZERO
var _investigate_destination: Vector3 = Vector3.ZERO
var _investigate_pause_timer: float = 0.0
var _investigate_moving: bool = false
var _current_target_is_a: bool = false
var _has_target: bool = false
var _state_changed: bool = false


func tick(delta: float, ctx: Dictionary) -> Dictionary:
	_state_changed = false
	_ensure_initial_target(ctx)

	var sees_player: bool = _check_player_visibility(ctx)
	var movement_delta: Vector3 = _run_state_machine(delta, ctx, sees_player)
	var detection_result: Dictionary = _compute_detection(delta, ctx, sees_player)

	var move_delta_length: float = movement_delta.length()
	var move_dir: Vector3 = Vector3.ZERO
	var target_speed: float = 0.0
	if move_delta_length > 0.0:
		move_dir = movement_delta / move_delta_length
		target_speed = move_delta_length / delta if delta > 0.0 else 0.0

	return {
		"move_dir": move_dir,
		"target_speed": target_speed,
		"move_delta": movement_delta,
		"next_state": _current_state,
		"state_label_text": _current_state,
		"state_changed": _state_changed,
		"detection_delta": detection_result.get("delta", 0.0),
		"caught_player": detection_result.get("will_catch", false),
	}


func get_state() -> String:
	return _current_state


func _run_state_machine(delta: float, ctx: Dictionary, sees_player: bool) -> Vector3:
	match _current_state:
		STATE_PATROL:
			var patrol_delta: Vector3 = _update_patrol(delta, ctx)
			if sees_player:
				_start_alert(ctx)
			return patrol_delta
		STATE_ALERT:
			_update_alert_state(delta, sees_player, ctx)
			return Vector3.ZERO
		STATE_INVESTIGATE:
			var investigate_delta: Vector3 = _update_investigate_state(delta, ctx)
			if sees_player:
				_start_alert(ctx)
			return investigate_delta
	return Vector3.ZERO


func _update_patrol(delta: float, ctx: Dictionary) -> Vector3:
	if not _has_target:
		return Vector3.ZERO

	var target_position: Vector3 = PositionUtils.clamp_to_plane(
		_get_current_target(ctx), ctx.get("initial_y", 0.0), ctx.get("plane_z", 0.0)
	)
	var to_target: Vector3 = target_position - ctx.get("position", Vector3.ZERO)
	var distance: float = to_target.length()

	if distance < GameConstants.POSITION_SNAP_THRESHOLD:
		_switch_target()
		return Vector3.ZERO

	var move_distance: float = min(distance, ctx.get("patrol_speed", 0.0) * delta)
	var direction: Vector3 = to_target.normalized()
	_update_facing(direction.x)
	return direction * move_distance


func _update_alert_state(delta: float, sees_player: bool, ctx: Dictionary) -> void:
	if sees_player:
		_alert_timer += delta
		_record_last_seen_position(ctx)
	else:
		_start_investigation(ctx)


func _update_investigate_state(delta: float, ctx: Dictionary) -> Vector3:
	if _investigate_moving:
		return _move_to_investigate_destination(delta, ctx)

	_investigate_pause_timer += delta
	if _investigate_pause_timer >= ctx.get("investigate_pause_time", 0.0):
		_return_to_patrol(ctx)
	return Vector3.ZERO


func _move_to_investigate_destination(delta: float, ctx: Dictionary) -> Vector3:
	var to_dest: Vector3 = _investigate_destination - ctx.get("position", Vector3.ZERO)
	var distance_x: float = abs(to_dest.x)

	if distance_x < GameConstants.POSITION_SNAP_THRESHOLD:
		return _snap_to_destination(ctx)

	var direction_sign: float = 1.0 if to_dest.x >= 0.0 else -1.0
	var move_distance: float = min(distance_x, ctx.get("patrol_speed", 0.0) * delta)
	_facing = Vector3(direction_sign, 0, 0)
	return Vector3(direction_sign * move_distance, 0, 0)


func _snap_to_destination(ctx: Dictionary) -> Vector3:
	_investigate_moving = false
	_investigate_pause_timer = 0.0
	var current_x: float = ctx.get("position", Vector3.ZERO).x
	return Vector3(_investigate_destination.x - current_x, 0, 0)


func _return_to_patrol(ctx: Dictionary) -> void:
	_investigate_moving = false
	_investigate_pause_timer = 0.0
	_choose_next_patrol_target(ctx)
	_change_state(STATE_PATROL)


func _start_alert(ctx: Dictionary) -> void:
	_alert_timer = 0.0
	_record_last_seen_position(ctx)
	_change_state(STATE_ALERT)


func _start_investigation(ctx: Dictionary) -> void:
	_alert_timer = 0.0
	if _last_seen_position == Vector3.ZERO:
		_record_last_seen_position(ctx)
	_investigate_destination = Vector3(
		_last_seen_position.x, ctx.get("initial_y", 0.0), ctx.get("plane_z", 0.0)
	)
	_investigate_moving = true
	_investigate_pause_timer = 0.0
	_change_state(STATE_INVESTIGATE)


func _choose_next_patrol_target(ctx: Dictionary) -> void:
	var waypoint_a: Variant = ctx.get("waypoint_a")
	var waypoint_b: Variant = ctx.get("waypoint_b")
	if waypoint_a == null or waypoint_b == null:
		return

	var distance_to_a: float = abs(ctx.get("position", Vector3.ZERO).x - waypoint_a.x)
	var distance_to_b: float = abs(ctx.get("position", Vector3.ZERO).x - waypoint_b.x)
	_current_target_is_a = distance_to_a >= distance_to_b


func _switch_target() -> void:
	_current_target_is_a = not _current_target_is_a


func _get_current_target(ctx: Dictionary) -> Vector3:
	var waypoint_a: Variant = ctx.get("waypoint_a")
	var waypoint_b: Variant = ctx.get("waypoint_b")
	return waypoint_a if _current_target_is_a else waypoint_b


func _ensure_initial_target(ctx: Dictionary) -> void:
	if _has_target:
		return
	var waypoint_a: Variant = ctx.get("waypoint_a")
	var waypoint_b: Variant = ctx.get("waypoint_b")
	if waypoint_a == null and waypoint_b == null:
		return
	_current_target_is_a = waypoint_b == null
	_has_target = true


func _record_last_seen_position(ctx: Dictionary) -> void:
	var player_position: Variant = ctx.get("player_position")
	if player_position == null:
		return
	_last_seen_position = PositionUtils.clamp_to_plane(
		player_position, ctx.get("initial_y", 0.0), ctx.get("plane_z", 0.0)
	)


func _check_player_visibility(ctx: Dictionary) -> bool:
	var player_position: Variant = ctx.get("player_position")
	if player_position == null or ctx.get("player_hidden", true):
		return false

	var to_player: Vector3 = player_position - ctx.get("position", Vector3.ZERO)
	var planar_offset: Vector3 = Vector3(to_player.x, 0, to_player.z)
	var planar_distance: float = planar_offset.length()
	if planar_distance == 0.0 or planar_distance > ctx.get("detection_distance", 0.0):
		return false

	return _is_player_in_view_cone(planar_offset.normalized(), ctx.get("cone_half_angle_deg", 0.0))


func _is_player_in_view_cone(to_player_dir: Vector3, cone_half_angle_deg: float) -> bool:
	var facing: Vector3 = _facing.normalized()
	if facing.length() == 0.0:
		facing = Vector3(1, 0, 0)

	var dot: float = clamp(facing.dot(to_player_dir), -1.0, 1.0)
	var angle: float = rad_to_deg(acos(dot))
	return angle <= cone_half_angle_deg


func _update_facing(direction_x: float) -> void:
	if abs(direction_x) > GameConstants.VELOCITY_FLIP_THRESHOLD:
		_facing = Vector3(1, 0, 0) if direction_x > 0.0 else Vector3(-1, 0, 0)


func _compute_detection(delta: float, ctx: Dictionary, sees_player: bool) -> Dictionary:
	var detection_meter: float = ctx.get("detection_meter", 0.0)
	var fill: bool = (
		_current_state == STATE_ALERT
		and sees_player
		and _alert_timer >= ctx.get("alert_grace_time", 0.0)
	)

	var new_meter: float = detection_meter
	if fill:
		new_meter = min(
			GameConstants.DETECTION_METER_MAX,
			detection_meter + ctx.get("detection_fill_rate", 0.0) * delta
		)
	else:
		new_meter = max(0.0, detection_meter - ctx.get("detection_decay_rate", 0.0) * delta)

	return {
		"delta": new_meter - detection_meter,
		"will_catch": new_meter >= GameConstants.DETECTION_METER_MAX,
	}


func _change_state(new_state: String) -> void:
	if _current_state == new_state:
		return
	_current_state = new_state
	_state_changed = true
