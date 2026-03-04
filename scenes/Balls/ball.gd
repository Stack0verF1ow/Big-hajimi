extends RigidBody2D
class_name Ball

# ── FSM 状态枚举 ─────────────────────────────────────────────
enum State { IDLE, MERGING, DEAD }

# ── 对外信号，由 Game 统一监听 ────────────────────────────────
signal want_to_merge(ball_a: Ball, ball_b: Ball)

# ── 数据属性 ─────────────────────────────────────────────────
var ball_type: int       # config 中的 id (1, 2, 3...)
var ball_index: int      # config 数组下标 (0, 1, 2...)，用于查找"下一级"
var score_value: int
var _pending_data: Dictionary

# ── FSM 内部管理 ─────────────────────────────────────────────
var _current_state: BallState
var _state_factory := BallStateFactory.new()

@onready var sprite     = $Sprite2D
@onready var collision  = %BallCollisionShape
@onready var sfx_player = $AudioStreamPlayer2D

# ── 由 BallBuilder 在实例化后立即调用 ────────────────────────
func setup(data: Dictionary) -> void:
	_pending_data = data
	ball_type   = data.get("type",  0)
	ball_index  = data.get("index", 0)
	score_value = data.get("score", 0)

func _ready() -> void:
	_apply_visual_data()
	# 启动 FSM，初始状态为 IDLE
	_transition_to(State.IDLE)

# ── 视觉 / 物理初始化（与 FSM 无关）────────────────────────
func _apply_visual_data() -> void:
	if _pending_data.is_empty():
		return

	var tex = _pending_data.get("texture")
	var rad = _pending_data.get("radius", 50.0)

	var shape = CircleShape2D.new()
	shape.radius = rad
	collision.shape = shape

	if tex:
		sprite.texture = tex
		var tex_size = tex.get_size()
		var d = rad * 2.0
		sprite.scale = Vector2(d / tex_size.x, d / tex_size.y)

	var sfx = _pending_data.get("sound")
	if sfx:
		sfx_player.stream = sfx

# ── FSM 核心：状态转换 ────────────────────────────────────────
func _transition_to(new_state: State, data: BallStateData = BallStateData.new()) -> void:
	# 清理旧状态
	if is_instance_valid(_current_state):
		_current_state.queue_free()

	# 创建新状态，注入上下文后再挂载
	var state = _state_factory.get_fresh_state(new_state)
	state.setup(self, data)
	state.state_transition_requested.connect(_on_state_transition_requested)
	add_child(state)
	_current_state = state

func _on_state_transition_requested(new_state: State, data: BallStateData) -> void:
	_transition_to(new_state, data)

# ── 外部查询接口（供 BallStateIdle 仲裁用）───────────────────
func is_idle() -> bool:
	return is_instance_valid(_current_state) and _current_state is BallStateIdle
