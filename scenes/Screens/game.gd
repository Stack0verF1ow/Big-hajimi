class_name Game
extends Node2D

@onready var hajimi_container:  StaticBody2D    = %HajimiContainer
@onready var launcher_manager:  LauncherManager = %LauncherManager
@onready var ui:                UI              = %UI

var director:        BallDirector
var score:           int = 0
var _max_ball_index: int = 0
var _config_data:    Array[Dictionary] = []                     # ← 5. 明确元素类型
var _ball_queue    := BallQueue.new()

func _ready() -> void:
	var builder = BallBuilder.new()
	director    = BallDirector.new(builder)
	_config_data = DataLoader.load_ball_config("res://data/ball_config.json")
	director.load_data(_config_data)
	_max_ball_index = _config_data.size() - 1

	ui.setup(_config_data)

	# Game 只和 LauncherManager 通信
	launcher_manager.launch_requested.connect(_on_launch_requested)
	_ball_queue.queue_changed.connect(_on_queue_changed)
	_on_queue_changed(_ball_queue.peek_all())

# 玩家触发发射 → 从队列取球 → 在发射器位置生成
func _on_launch_requested() -> void:
	var index := _ball_queue.consume()
	_create_and_add_ball(index, launcher_manager.get_spawn_position())

# 队列变化 → 更新发射器预览 + UI
func _on_queue_changed(indices: Array[int]) -> void:
	var config: Dictionary = _config_data[indices[0]]
	launcher_manager.show_next_ball(config)
	ui.on_queue_changed(indices)

# ── 以下逻辑不变 ─────────────────────────────────────────────

func _create_and_add_ball(index: int, pos: Vector2) -> Ball:
	var ball = director.create_ball_by_index(index)
	if not ball:
		return null
	add_child(ball)
	ball.global_position = pos
	ball.want_to_merge.connect(_on_merge_requested)
	return ball

func _on_merge_requested(ball_a: Ball, ball_b: Ball) -> void:
	if not is_instance_valid(ball_a) or not is_instance_valid(ball_b):
		return

	var merge_pos  = (ball_a.global_position + ball_b.global_position) / 2.0
	var next_index = ball_a.ball_index + 1
	var is_max     = next_index > _max_ball_index

	score += ball_a.score_value + ball_b.score_value
	ui.update_score(score)

	ball_a._transition_to(Ball.State.DEAD, BallStateData.build().set_play_merge_sfx(is_max))
	ball_b._transition_to(Ball.State.DEAD, BallStateData.build().set_play_merge_sfx(false))

	if is_max:
		return

	call_deferred("_spawn_merged_ball", next_index, merge_pos)

func _spawn_merged_ball(next_index: int, pos: Vector2) -> void:
	_create_and_add_ball(next_index, pos)
