extends CanvasLayer

@onready var detection_bar: ProgressBar = %DetectionBar
@onready var hidden_status_label: Label = %HiddenStatusLabel

var _player: Node = null
var _enemy: Node = null
var _target_refresh_timer: float = 0.0


func _ready() -> void:
	_refresh_targets()
	set_process(true)


func _process(delta: float) -> void:
	_target_refresh_timer += delta
	if _target_refresh_timer >= 1.0:
		_target_refresh_timer = 0.0
		_refresh_targets()
	_update_detection_bar()
	_update_hidden_status()


func _refresh_targets() -> void:
	var tree := get_tree()
	if not tree:
		return
	_player = tree.get_first_node_in_group("player")
	_enemy = tree.get_first_node_in_group("enemy")


func _update_detection_bar() -> void:
	var detection_value: float = 0.0
	if _enemy and _enemy.has_method("get_detection_meter"):
		detection_value = _enemy.get_detection_meter()
	detection_bar.value = detection_value
	detection_bar.tooltip_text = "%0.0f%%" % detection_value


func _update_hidden_status() -> void:
	var hidden_text: String = "VISIBLE"
	if _player and _player.has_variable("is_hidden") and _player.is_hidden:
		hidden_text = "HIDDEN"
	hidden_status_label.text = hidden_text
