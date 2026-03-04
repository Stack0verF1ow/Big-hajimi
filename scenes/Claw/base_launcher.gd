class_name BaseLauncher
extends Node2D

# LauncherManager 监听此信号，再转发给 Game
signal launch_requested

# 冷却中不允许发射
var _cooldown_time: float = 0.2
var _is_cooling_down: bool = false

@onready var spawn_point: Marker2D = $SpawnPoint

# ── 子类必须实现 ──────────────────────────────────────────────

# 展示即将生成的球（由 LauncherManager 在队列变化时调用）
func show_next_ball(_config: Dictionary) -> void:
	push_error("BaseLauncher.show_next_ball() 未实现")

# ── 通用逻辑（子类可直接复用）────────────────────────────────

func get_spawn_position() -> Vector2:
	return spawn_point.global_position

func try_launch() -> void:
	if _is_cooling_down:
		return
	_start_cooldown()
	launch_requested.emit()

func _start_cooldown() -> void:
	_is_cooling_down = true
	await get_tree().create_timer(_cooldown_time).timeout
	_is_cooling_down = false
