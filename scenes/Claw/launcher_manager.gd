class_name LauncherManager
extends Node2D

var _current_launcher: BaseLauncher

func _ready() -> void:
	_current_launcher = get_child(0) as BaseLauncher

# ── GameScreen / GameManager 调用的接口 ──────────────────────

# 接收贴图路径和半径，不持有 _config_data
func show_next_ball(texture_path: String, radius: float) -> void:
	if is_instance_valid(_current_launcher):
		_current_launcher.show_next_ball(texture_path, radius)

func get_spawn_position() -> Vector2:
	if is_instance_valid(_current_launcher):
		return _current_launcher.get_spawn_position()
	return global_position

# 运行时切换发射器（弹弓、大炮等扩展入口）
func switch_launcher(new_launcher: BaseLauncher) -> void:
	if is_instance_valid(_current_launcher):
		_current_launcher.queue_free()
	_current_launcher = new_launcher
	add_child(new_launcher)
