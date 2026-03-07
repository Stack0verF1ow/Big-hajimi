extends RigidBody2D
class_name Ball

# ── FSM 状态枚举 ─────────────────────────────────────────────
enum State { IDLE, MERGING, DEAD }

@warning_ignore("unused_signal")
signal want_to_merge(ball_a: Ball, ball_b: Ball)

# ── 数据属性 ─────────────────────────────────────────────────
var ball_type:        int
var ball_index:       int
var score_value:      int
var spawn_sfx:        AudioStream   # 该球独有的生成音效
var spawn_sfx_chance: float         # 生成音效触发概率 0.0~1.0
var _pending_data:    Dictionary

# ── FSM ──────────────────────────────────────────────────────
var _current_state: BallState
var _state_factory := BallStateFactory.new()

@onready var sprite    = $Sprite2D
@onready var collision = %BallCollisionShape
# 注意：已移除 AudioStreamPlayer2D，音效统一由 SoundPlayer 处理

func setup(data: Dictionary) -> void:
	_pending_data     = data
	ball_type         = data.get("type",             0)
	ball_index        = data.get("index",            0)
	score_value       = data.get("score",            0)
	spawn_sfx         = data.get("spawn_sfx",        null)
	spawn_sfx_chance  = data.get("spawn_sfx_chance", 0.0)

func _ready() -> void:
	_apply_visual_data()
	_transition_to(State.IDLE)

func _apply_visual_data() -> void:
	if _pending_data.is_empty():
		return
	var tex = _pending_data.get("texture")
	var rad: float = _pending_data.get("radius", 50.0)

	var shape = CircleShape2D.new()
	shape.radius = rad
	collision.shape = shape

	if tex:
		sprite.texture = tex
		var tex_size : Vector2 = tex.get_size()
		var d := rad * 2.0
		sprite.scale = Vector2(d / tex_size.x, d / tex_size.y)

func _transition_to(new_state: State, data: BallStateData = BallStateData.new()) -> void:
	if is_instance_valid(_current_state):
		_current_state.queue_free()

	var state := _state_factory.get_fresh_state(new_state)
	state.setup(self, data)
	state.state_transition_requested.connect(_on_state_transition_requested)
	add_child(state)
	_current_state = state

func _on_state_transition_requested(new_state: State, data: BallStateData) -> void:
	_transition_to(new_state, data)

func is_idle() -> bool:
	return is_instance_valid(_current_state) and _current_state is BallStateIdle
