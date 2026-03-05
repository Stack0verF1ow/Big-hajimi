extends Node

enum State { IN_PLAY, GAME_OVER, PAUSE }

# ── 场景依赖（由 GameScene._ready() 注册）───────────────────
var ui:               UI
var launcher_manager: LauncherManager
var ball_scene_root:  Node2D   # 球生成的父节点（容器场景根节点）

# ── 游戏数据 ─────────────────────────────────────────────────
var score:          int = 0
var max_ball_index: int = 0
var ball_queue    := BallQueue.new()

var director:     BallDirector
var _config_data: Array[Dictionary] = []

# ── FSM ──────────────────────────────────────────────────────
var _current_state:  GameState
var _state_factory := GameStateFactory.new()

func _ready() -> void:
	var builder  = BallBuilder.new()
	director     = BallDirector.new(builder)
	_config_data = DataLoader.load_ball_config("res://data/ball_config.json")
	director.load_data(_config_data)
	max_ball_index = _config_data.size() - 1

	# 监听队列变化，同步转发给 GameBus
	ball_queue.queue_changed.connect(_on_queue_changed)

# ── 场景注册入口（由 GameScene 调用）────────────────────────
func register_scene(
	p_ui: UI,
	p_launcher_manager: LauncherManager,
	p_ball_scene_root: Node2D
) -> void:
	ui               = p_ui
	launcher_manager = p_launcher_manager
	ball_scene_root  = p_ball_scene_root

	# 初始化 UI 并同步初始队列状态
	ui.setup(_config_data)
	launcher_manager.launch_requested.connect(func(): GameBus.launch_requested.emit())

	_on_queue_changed(ball_queue.peek_all())

	# 启动游戏
	_transition_to(State.IN_PLAY)

# ── FSM 核心 ─────────────────────────────────────────────────
func _transition_to(new_state: State, data: GameStateData = GameStateData.new()) -> void:
	if is_instance_valid(_current_state):
		_current_state.state_transition_requested.disconnect(_on_state_transition_requested)
		_current_state.queue_free()

	var state := _state_factory.get_fresh_state(new_state)
	state.setup(self, data)
	state.state_transition_requested.connect(_on_state_transition_requested)
	add_child(state)
	_current_state = state

func _on_state_transition_requested(new_state: State, data: GameStateData) -> void:
	_transition_to(new_state, data)

# ── 队列变化同步 ─────────────────────────────────────────────
func _on_queue_changed(indices: Array[int]) -> void:
	var config: Dictionary = _config_data[indices[0]]
	launcher_manager.show_next_ball(config)
	GameBus.queue_changed.emit(indices)
