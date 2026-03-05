class_name GameStateInPlay
extends GameState

func _enter_tree() -> void:
	GameBus.launch_requested.connect(_on_launch_requested)
	GameBus.ball_merge_requested.connect(_on_ball_merge_requested)
	GameBus.game_over_triggered.connect(_on_game_over_triggered)
	GameBus.pause_requested.connect(_on_pause_requested)
	
	MusicPlayer.play_game_music()

func _exit_tree() -> void:
	GameBus.launch_requested.disconnect(_on_launch_requested)
	GameBus.ball_merge_requested.disconnect(_on_ball_merge_requested)
	GameBus.game_over_triggered.disconnect(_on_game_over_triggered)
	GameBus.pause_requested.disconnect(_on_pause_requested)

# ── 球的创建（从 GameManager 下移，只有此状态需要）──────────
func _create_ball(index: int, pos: Vector2) -> void:
	var ball := game_manager.director.create_ball_by_index(index)
	if not ball:
		return
	game_manager.ball_scene_root.add_child(ball)
	ball.global_position = pos
	# want_to_merge 直接连到 GameBus 的 emit 方法，无需 lambda 中转
	ball.want_to_merge.connect(GameBus.ball_merge_requested.emit)

# ── 发射 ─────────────────────────────────────────────────────
func _on_launch_requested() -> void:
	var index := game_manager.ball_queue.consume()
	_create_ball(index, game_manager.launcher_manager.get_spawn_position())

# ── 合并 ─────────────────────────────────────────────────────
func _on_ball_merge_requested(ball_a: Ball, ball_b: Ball) -> void:
	if not is_instance_valid(ball_a) or not is_instance_valid(ball_b):
		return

	var merge_pos  := (ball_a.global_position + ball_b.global_position) / 2.0
	var next_index := ball_a.ball_index + 1
	var is_max     := next_index > game_manager.max_ball_index

	game_manager.score += ball_a.score_value + ball_b.score_value
	GameBus.score_changed.emit(game_manager.score)

	ball_a._transition_to(Ball.State.DEAD, BallStateData.build().set_play_merge_sfx(is_max))
	ball_b._transition_to(Ball.State.DEAD, BallStateData.build().set_play_merge_sfx(false))

	if is_max:
		return

	call_deferred("_create_ball", next_index, merge_pos)

# ── 状态切换 ─────────────────────────────────────────────────
func _on_game_over_triggered() -> void:
	var data := GameStateData.build().set_final_score(game_manager.score)
	transition_state(GameManager.State.GAME_OVER, data)

func _on_pause_requested() -> void:
	transition_state(GameManager.State.PAUSE)
