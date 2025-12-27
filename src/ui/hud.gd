## Heads-Up Display (HUD)
##
## Displays player hidden status and enemy detection meter.
## Uses signals from player and enemy for efficient updates (no polling).
extends CanvasLayer

# Detection FX tuning
@export var fx_min_alpha: float = 0.0
@export var fx_max_alpha: float = 0.45
@export var bpm_min: float = 60.0
@export var bpm_max: float = 140.0
@export var beat_flash: float = 0.12  # maximum extra alpha at peak (scales with detection)

## Reference to player node
var _player: Node = null

## Reference to enemy node
var _enemy: Node = null

var _beat_timer: float = 0.0

@onready var detection_bar: Range = %DetectionBar
@onready var hidden_status_label: Label = %HiddenStatusLabel
@onready var _vignette: ColorRect = $Root/DirectionFX/Vignette


func _ready() -> void:
	# Scene owns layout + default visibility. Script only initializes dynamic FX.
	_vignette.self_modulate.a = 0.0
	_vignette.visible = false

	_connect_to_game_entities()
	var fx := $Root/DirectionFX
	fx.set_anchors_preset(Control.PRESET_FULL_RECT)

	assert(_vignette, "HUD requires node at $Root/DirectionFX/Vignette (ColorRect).")

	$Root/DirectionFX.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)


func _process(delta: float) -> void:
	if _vignette == null:
		return

	var det: float = detection_bar.value
	var t: float = clamp(det / 100.0, 0.0, 1.0)

	# If no detection, effect must be fully off.
	if t <= 0.0:
		_vignette.visible = false
		_vignette.self_modulate.a = 0.0
		_beat_timer = 0.0
		return

	_vignette.visible = true

	# Progressive darkening as detection rises.
	var base_alpha: float = lerpf(fx_min_alpha, fx_max_alpha, t * t)

	# Heartbeat frequency rises with detection.
	var bpm: float = lerpf(bpm_min, bpm_max, t)
	var beat_period: float = 60.0 / max(bpm, 1.0)

	# Beat phase in [0,1).
	_beat_timer = fmod(_beat_timer + delta, beat_period)
	var phase: float = _beat_timer / beat_period

	# Smooth heartbeat pulse: 0 at start/end, 1 at mid-beat.
	var pulse: float = 0.5 - 0.5 * cos(phase * TAU)

	# Shape alpha so it *relaxes* between beats and gets stronger with detection:
	# - Floor is below base_alpha, so the pulse is visually obvious.
	# - Peak grows above base_alpha, with amplitude scaling by detection.
	var floor_alpha: float = clampf(base_alpha * 0.4, 0.0, 1.0)
	var peak_alpha: float = clampf(base_alpha + (beat_flash * t), 0.0, 1.0)
	var a: float = lerpf(floor_alpha, peak_alpha, pulse)
	if Engine.get_frames_drawn() % 60 == 0:
		print("t=", t, " floor=", floor_alpha, " peak=", peak_alpha, " pulse=", pulse, " a=", a)
		print("beat_flash=", beat_flash, " fx_max_alpha=", fx_max_alpha)

	var m: Color = _vignette.self_modulate
	m.a = a
	_vignette.self_modulate = m


## Connects to player and enemy signals for reactive updates.
## Waits one frame to ensure scene tree is fully initialized.
func _connect_to_game_entities() -> void:
	await get_tree().process_frame  # Wait for scene tree to be ready

	_player = get_tree().get_first_node_in_group("player")
	_enemy = get_tree().get_first_node_in_group("enemy")

	# Connect to player hide state signal
	if _player and _player.has_signal("hidden_state_changed"):
		_player.hidden_state_changed.connect(_on_player_hidden_state_changed)
		# Initialize display with current state
		_on_player_hidden_state_changed(_player.is_hidden)

	# Connect to enemy detection meter signal
	if _enemy and _enemy.has_signal("detection_meter_changed"):
		_enemy.detection_meter_changed.connect(_on_detection_meter_changed)
		# Initialize display with current value
		if _enemy.has_method("get_detection_meter"):
			_on_detection_meter_changed(_enemy.get_detection_meter())


## Updates hidden status label when player hide state changes
func _on_player_hidden_state_changed(is_hidden: bool) -> void:
	hidden_status_label.text = "HIDDEN" if is_hidden else "VISIBLE"


## Updates detection bar when enemy detection meter changes
func _on_detection_meter_changed(value: float) -> void:
	detection_bar.value = value
