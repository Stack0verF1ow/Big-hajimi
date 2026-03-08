class_name GameStateInPlay
extends GameState

const LAUNCH_COOLDOWN := 0.5
var _is_cooling_down: bool = false

func _enter_tree() -> void:
	game_manager.interactable_area.clicked.connect(_on_area_clicked)
	GameBus.ball_merge_requested.connect(_on_ball_merge_requested)
	GameBus.game_over_triggered.connect(_on_game_over_triggered)
	GameBus.game_to_be_pause.connect(_on_game_to_be_pause)

func _exit_tree() -> void:
	game_manager.interactable_area.clicked.disconnect(_on_area_clicked)
	GameBus.ball_merge_requested.disconnect(_on_ball_merge_requested)
	GameBus.game_over_triggered.disconnect(_on_game_over_triggered)
	GameBus.game_to_be_pause.disconnect(_on_game_to_be_pause)

# ── 发球 ─────────────────────────────────────────────────────

func _on_area_clicked() -> void:
	if _is_cooling_down:
		return
	var index := game_manager.ball_queue.consume()
	_create_ball(index, game_manager.launcher_manager.get_spawn_position())
	_start_cooldown()

func _create_ball(index: int, pos: Vector2) -> void:
	var ball := game_manager.director.create_ball_by_index(index)
	if not ball:
		return
	game_manager.hajimi_container.add_child(ball)
	ball.global_position = pos
	ball.want_to_merge.connect(GameBus.ball_merge_requested.emit)

func _start_cooldown() -> void:
	_is_cooling_down = true
	await get_tree().create_timer(LAUNCH_COOLDOWN).timeout
	_is_cooling_down = false

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

func _on_game_to_be_pause() -> void:
	transition_state(GameManager.State.PAUSE)

func _on_game_over_triggered() -> void:
	var data := GameStateData.build().set_final_score(game_manager.score)
	transition_state(GameManager.State.GAME_OVER, data)
