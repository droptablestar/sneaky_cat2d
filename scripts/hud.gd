## Heads-Up Display (HUD)
##
## Displays player hidden status and enemy detection meter.
## Uses signals from player and enemy for efficient updates (no polling).
extends CanvasLayer

## Detection meter progress bar (0-100)
@onready var detection_bar: ProgressBar = %DetectionBar

## Label showing HIDDEN or VISIBLE status
@onready var hidden_status_label: Label = %HiddenStatusLabel

## Reference to player node
var _player: Node = null

## Reference to enemy node
var _enemy: Node = null


func _ready() -> void:
	_connect_to_game_entities()


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
		_on_player_hidden_state_changed(
			_player.is_hidden if _player.has_variable("is_hidden") else false
		)

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
