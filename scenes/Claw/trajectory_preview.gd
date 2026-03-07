class_name TrajectoryPreview
extends Line2D

func _ready() -> void:
	default_color = Color(1.0, 1.0, 1.0, 0.35)
	width = 1.5

# 发射器每帧调用，直接替换所有点
@warning_ignore("shadowed_variable_base_class")
func update_points(points: Array[Vector2]) -> void:
	clear_points()
	for p in points:
		add_point(p)
