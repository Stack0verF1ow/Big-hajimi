class_name ClawLauncher
extends BaseLauncher

# 水平移动边界（由 Game 或 LauncherManager 根据容器宽度设置）
var _x_min: float = -300.0
var _x_max: float =  300.0
var _ball_radius: float = 0.0   # 当前球半径，用于修正 clamp 边界

@onready var visual:       Sprite2D = $Visual
@onready var preview_ball: Sprite2D = $PreviewBall

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

func set_bounds(x_min: float, x_max: float) -> void:
	_x_min = x_min
	_x_max = x_max
