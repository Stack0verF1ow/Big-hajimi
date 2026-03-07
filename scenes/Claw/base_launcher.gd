class_name BaseLauncher
extends Node2D

signal launch_requested

var _cooldown_time:    float = 0.5
var _is_cooling_down:  bool  = false

@onready var spawn_point:         Marker2D          = $SpawnPoint
@onready var trajectory_preview:  TrajectoryPreview = $SpawnPoint/TrajectoryPreview

# ── 子类必须实现 ──────────────────────────────────────────────

func show_next_ball(_config: Dictionary) -> void:
	push_error("BaseLauncher.show_next_ball() 未实现")

# 子类覆盖此方法返回轨迹点数组（局部坐标，相对于 TrajectoryPreview）
# 默认实现为空，不显示轨迹
func get_trajectory_points() -> Array[Vector2]:
	return []

# ── 通用逻辑 ─────────────────────────────────────────────────

func get_spawn_position() -> Vector2:
	return spawn_point.global_position

func try_launch() -> void:
	if _is_cooling_down:
		return
	_start_cooldown()
	launch_requested.emit()

func _process(_delta: float) -> void:
	trajectory_preview.update_points(get_trajectory_points())

func _start_cooldown() -> void:
	_is_cooling_down = true
	await get_tree().create_timer(_cooldown_time).timeout
	_is_cooling_down = false
