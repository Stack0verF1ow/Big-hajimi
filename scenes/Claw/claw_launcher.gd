class_name ClawLauncher
extends BaseLauncher

var _x_min: float = 0.0
var _x_max: float = 0.0
var _ball_radius: float = 0.0

@onready var visual:       Node2D   = $Visual
@onready var preview_ball: Sprite2D = $PreviewBall

func _ready() -> void:
	# 从 viewport 动态读取，与实际窗口始终一致
	var viewport_width := get_viewport_rect().size.x
	_x_min = 0.0
	_x_max = viewport_width

func _process(_delta: float) -> void:
	_follow_mouse()
	if Input.is_action_just_pressed("create"):
		try_launch()

# ── BaseLauncher 接口实现 ─────────────────────────────────────

func show_next_ball(config: Dictionary) -> void:
	var tex: Texture2D = load(config["texture"])
	var rad: float = config.get("radius", 50.0)
	_ball_radius = rad

	preview_ball.texture = tex
	var tex_size := tex.get_size()
	var d := rad * 2.0
	preview_ball.scale = Vector2(d / tex_size.x, d / tex_size.y)

# ── 私有 ─────────────────────────────────────────────────────

func _follow_mouse() -> void:
	var mouse_x := get_global_mouse_position().x
	# 左右边界各缩进一个球半径，防止球体超出容器
	var clamped_x := clampf(mouse_x, _x_min + _ball_radius, _x_max - _ball_radius)
	global_position.x = clamped_x
