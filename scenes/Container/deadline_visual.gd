class_name DeadLineVisual
extends Line2D

const COLOR_NORMAL  := Color(1.0, 1.0, 1.0, 0.55)
const COLOR_WARNING := Color(1.0, 0.15, 0.15, 1.0)

var _tween: Tween

func _ready() -> void:
	# 两个端点在编辑器里直接拖，或在此设置
	default_color = COLOR_NORMAL
	width = 2.0

func start_flash() -> void:
	_kill_tween()
	_tween = create_tween().set_loops()
	_tween.tween_property(self, "default_color", COLOR_WARNING, 0.35)
	_tween.tween_property(self, "default_color", COLOR_NORMAL,  0.35)

func stop_flash() -> void:
	_kill_tween()
	_tween = create_tween()
	_tween.tween_property(self, "default_color", COLOR_NORMAL, 0.3)

func _kill_tween() -> void:
	if is_instance_valid(_tween):
		_tween.kill()
