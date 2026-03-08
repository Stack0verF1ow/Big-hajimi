class_name BaseLauncher
extends Node2D

@onready var spawn_point:        Marker2D          = $SpawnPoint
@onready var trajectory_preview: TrajectoryPreview = $SpawnPoint/TrajectoryPreview

# ── 子类必须实现 ──────────────────────────────────────────────

# 接收贴图路径和半径，不持有 _config_data
func show_next_ball(_texture_path: String, _radius: float) -> void:
	push_error("BaseLauncher.show_next_ball() 未实现")

func get_trajectory_points() -> Array[Vector2]:
	return []

# ── 通用逻辑 ─────────────────────────────────────────────────

func get_spawn_position() -> Vector2:
	return spawn_point.global_position

func _process(_delta: float) -> void:
	trajectory_preview.update_points(get_trajectory_points())
