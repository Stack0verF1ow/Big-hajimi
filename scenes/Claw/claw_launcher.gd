class_name ClawLauncher
extends BaseLauncher

var _x_min:       float = 0.0
var _x_max:       float = 0.0
var _ball_radius: float = 0.0

@onready var visual:       Node2D   = $Visual
@onready var preview_ball: Sprite2D = $PreviewBall

func _ready() -> void:
	var viewport_width := get_viewport_rect().size.x
	_x_min = 0.0
	_x_max = viewport_width

func _process(delta: float) -> void:
	_follow_mouse()
	super._process(delta)   # 父类更新轨迹预览

# ── BaseLauncher 接口实现 ─────────────────────────────────────

func show_next_ball(texture_path: String, radius: float) -> void:
	_ball_radius = radius
	var tex := load(texture_path) as Texture2D
	if not tex:
		return
	preview_ball.texture = tex
	var d := radius * 2.0
	var tex_size := tex.get_size()
	preview_ball.scale = Vector2(d / tex_size.x, d / tex_size.y)

func get_trajectory_points() -> Array[Vector2]:
	var remaining_height := get_viewport_rect().size.y - spawn_point.global_position.y
	return [Vector2.ZERO, Vector2(0.0, remaining_height)]

# ── 私有 ─────────────────────────────────────────────────────

func _follow_mouse() -> void:
	var mouse_x   := get_global_mouse_position().x
	var clamped_x := clampf(mouse_x, _x_min + _ball_radius, _x_max - _ball_radius)
	global_position.x = clamped_x
