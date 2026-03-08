extends Node

enum State { IN_PLAY, GAME_OVER, PAUSE }

# ── 场景依赖 ─────────────────────────────────────────────────
var hajimi_container:  Node2D
var launcher_manager:  LauncherManager
var interactable_area: InteractableArea

# ── 游戏数据 ─────────────────────────────────────────────────
var score:          int = 0
var max_ball_index: int = 0
var ball_queue    := BallQueue.new()
var director:      BallDirector
var _config_data:  Array[Dictionary] = []

# ── FSM ──────────────────────────────────────────────────────
var _current_state: GameState
var _state_factory := GameStateFactory.new()

func _ready() -> void:
	var builder  = BallBuilder.new()
	director     = BallDirector.new(builder)
	_config_data = DataLoader.load_ball_config("res://data/ball_config.json")
	director.load_data(_config_data)
	max_ball_index = _config_data.size() - 1
	ball_queue.queue_changed.connect(_on_queue_changed)

func register_scene(
	p_hajimi_container:  Node2D,
	p_launcher_manager:  LauncherManager,
	p_interactable_area: InteractableArea
) -> void:
	hajimi_container  = p_hajimi_container
	launcher_manager  = p_launcher_manager
	interactable_area = p_interactable_area
	score = 0
	_on_queue_changed(ball_queue.peek_all())
	_transition_to(State.IN_PLAY)

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

func _on_queue_changed(indices: Array[int]) -> void:
	var cfg0 := _config_data[indices[0]]
	GameBus.launcher_preview_updated.emit(cfg0["texture"], cfg0.get("radius", 50.0))
	var paths: Array[String] = []
	for i in range(1, indices.size()):
		paths.append(_config_data[indices[i]]["texture"])
	GameBus.queue_preview_updated.emit(paths)
