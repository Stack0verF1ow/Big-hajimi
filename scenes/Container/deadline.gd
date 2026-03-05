class_name DeadLine
extends Area2D

const GRACE_PERIOD := 3.0

var _balls_on_line: int = 0
var _timer: SceneTreeTimer = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if not body is Ball:
		return
	_balls_on_line += 1
	if _balls_on_line == 1:
		_start_timer()

func _on_body_exited(body: Node) -> void:
	if not body is Ball:
		return
	_balls_on_line -= 1
	if _balls_on_line == 0:
		_cancel_timer()

func _start_timer() -> void:
	_cancel_timer()
	_timer = get_tree().create_timer(GRACE_PERIOD)
	_timer.timeout.connect(_on_grace_period_ended)

func _cancel_timer() -> void:
	if _timer != null:
		if _timer.timeout.is_connected(_on_grace_period_ended):
			_timer.timeout.disconnect(_on_grace_period_ended)
		_timer = null

func _on_grace_period_ended() -> void:
	if _balls_on_line > 0:
		# 不再持有 Game 引用，直接广播给 GameBus
		GameBus.game_over_triggered.emit()
