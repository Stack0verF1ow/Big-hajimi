class_name Game
extends Node2D

@onready var hajimi_container: StaticBody2D = %HajimiContainer
@onready var spawn_point: Marker2D          = %SpawnPoint

var director: BallDirector
var score: int = 0
var _max_ball_index: int = 0

func _ready() -> void:
	var builder = BallBuilder.new()
	director    = BallDirector.new(builder)
	var data    = DataLoader.load_ball_config("res://data/ball_config.json")
	director.load_data(data)
	_max_ball_index = data.size() - 1

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("create"):
		spawn_ball()

# ── 投放新球 ─────────────────────────────────────────────────
func spawn_ball() -> void:
	var random_index = randi() % 3
	_create_and_add_ball(random_index, get_global_mouse_position())

# ── 统一创建入口 ──────────────────────────────────────────────
func _create_and_add_ball(index: int, pos: Vector2) -> Ball:
	var ball = director.create_ball_by_index(index)
	if not ball:
		return null
	add_child(ball)
	ball.global_position = pos
	ball.want_to_merge.connect(_on_merge_requested)
	return ball

# ── 合并处理：由 BallStateMerging 触发 ───────────────────────
func _on_merge_requested(ball_a: Ball, ball_b: Ball) -> void:
	if not is_instance_valid(ball_a) or not is_instance_valid(ball_b):
		return

	var merge_pos  = (ball_a.global_position + ball_b.global_position) / 2.0
	var next_index = ball_a.ball_index + 1
	var is_max = next_index > _max_ball_index

	# 得分
	score += ball_a.score_value + ball_b.score_value
	print("合成！得分 +%d，总分：%d" % [ball_a.score_value + ball_b.score_value, score])

	# 只有最大球消除时才携带播放标志
	var dead_data = BallStateData.build().set_play_merge_sfx(is_max)
	ball_a._transition_to(Ball.State.DEAD, dead_data)
	ball_b._transition_to(Ball.State.DEAD, dead_data)

	# 最大球合并 → 仅消除，不生成新球
	if is_max:
		print("🎉 最大球合并消除！")
		return

	# 生成下一级球，deferred 等本帧物理结束
	call_deferred("_spawn_merged_ball", next_index, merge_pos)

func _spawn_merged_ball(next_index: int, pos: Vector2) -> void:
	_create_and_add_ball(next_index, pos)
