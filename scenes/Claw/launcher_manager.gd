class_name LauncherManager
extends Node2D

# 转发给 Game 的信号
signal launch_requested

var _current_launcher: BaseLauncher

func _ready() -> void:
	# 默认使用第一个子节点作为初始发射器
	_activate_launcher(get_child(0) as BaseLauncher)

# ── Game 调用的接口 ───────────────────────────────────────────

# 队列变化时由 Game 调用，更新预览球显示
func show_next_ball(config: Dictionary) -> void:
	if is_instance_valid(_current_launcher):
		_current_launcher.show_next_ball(config)

# 获取当前发射器的生成坐标
func get_spawn_position() -> Vector2:
	if is_instance_valid(_current_launcher):
		return _current_launcher.get_spawn_position()
	return global_position

# 运行时切换发射器（弹弓、大炮等扩展入口）
func switch_launcher(new_launcher: BaseLauncher) -> void:
	if is_instance_valid(_current_launcher):
		_current_launcher.launch_requested.disconnect(_on_launch_requested)
		_current_launcher.queue_free()
	_activate_launcher(new_launcher)
	add_child(new_launcher)

# ── 私有 ─────────────────────────────────────────────────────

func _activate_launcher(launcher: BaseLauncher) -> void:
	_current_launcher = launcher
	_current_launcher.launch_requested.connect(_on_launch_requested)

func _on_launch_requested() -> void:
	launch_requested.emit()
