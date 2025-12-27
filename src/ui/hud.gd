## Heads-Up Display (HUD)
##
## Displays player hidden status and enemy detection meter.
## Uses signals from player and enemy for efficient updates (no polling).
extends CanvasLayer

# Detection FX tuning
@export var fx_min_alpha: float = 0.0
@export var fx_max_alpha: float = 0.45
@export var bpm_min: float = 60.0
@export var bpm_max: float = 180.0
@export var beat_flash: float = 0.12  # extra alpha on beat
@export var beat_decay: float = 10.0  # higher = snappier falloff

## Reference to player node
var _player: Node = null

## Reference to enemy node
var _enemy: Node = null

var _det_norm: float = 0.0
var _beat_timer: float = 0.0
var _beat_kick: float = 0.0

@onready var detection_bar: Range = %DetectionBar
@onready var hidden_status_label: Label = %HiddenStatusLabel
@onready var _vignette: ColorRect = $Root/DirectionFX/Vignette
@onready var _direction_fx: Control = $Root/DirectionFX


func _ready() -> void:
	# Turn the HUD UI on (tscn has everything hidden)
	$Root.visible = true
	$Root/Panel.visible = true
	$Root/Panel/VBox.visible = true
	%HiddenStatusLabel.visible = true
	%DetectionBar.visible = true
	$Root/Panel/VBox/HiddenTitle.visible = true
	$Root/Panel/VBox/DetectionTitle.visible = true

	_direction_fx.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)

	var root: Control = $Root
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 0.0
	root.offset_top = 0.0
	root.offset_right = 0.0
	root.offset_bottom = 0.0

	# Ensure game starts with no overlay (no first-frame flash).
	$Root/DirectionFX.visible = true
	_vignette.visible = false

	_vignette.color.a = 1.0
	_vignette.self_modulate.a = 0.0
	_vignette.visible = false

	_connect_to_game_entities()
	assert(_vignette, "HUD requires node at $Root/DirectionFX/Vignette (ColorRect).")


func _process(delta: float) -> void:
	if _vignette == null:
		return

	# _det_norm must be in [0,1]
	var det: float = detection_bar.value
	var t: float = clamp(det / 100.0, 0.0, 1.0)

	# If no detection, effect must be fully off (no baseline pulse).
	if t <= 0.0:
		_vignette.visible = false
		_vignette.self_modulate.a = 0.0
	else:
		_vignette.visible = true
		var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * TAU * 2.0)  # 2Hz
		_vignette.self_modulate.a = t * pulse

	# Base intensity grows nonlinearly near the top
	var base_alpha: float = lerpf(fx_min_alpha, fx_max_alpha, t * t)

	# Beat frequency ramps with detection
	var bpm: float = lerpf(bpm_min, bpm_max, t)
	var beat_period: float = 60.0 / max(bpm, 1.0)

	_beat_timer += delta
	if _beat_timer >= beat_period:
		_beat_timer -= beat_period
		_beat_kick = 1.0

	# Decay the beat kick
	_beat_kick = max(_beat_kick - delta * beat_decay, 0.0)

	# Apply: alpha + small beat flash
	var a: float = clampf(base_alpha + _beat_kick * beat_flash, 0.0, 1.0)
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
	_det_norm = float(value) / float(GameConstants.DETECTION_METER_MAX)
