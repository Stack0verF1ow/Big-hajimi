class_name BallStateIdle
extends BallState

func _ready() -> void:
	ball.contact_monitor       = true
	ball.max_contacts_reported = 4
	ball.body_entered.connect(_on_body_entered)
	_try_play_spawn_sfx()

func _on_body_entered(body: Node) -> void:
	
	if not body is Ball:
		return
	if body.ball_type != ball.ball_type:
		return

	var data := BallStateData.build().set_contact_ball(body)
	transition_state(Ball.State.MERGING, data)

# ── 生成音效：按概率触发，委托 SoundPlayer 播放 ──────────────
func _try_play_spawn_sfx() -> void:
	if not ball.spawn_sfx:
		return
	# randf() 返回 0.0~1.0，与 chance 比较实现概率触发
	if randf() <= ball.spawn_sfx_chance:
		SoundPlayer.play_sfx_stream(ball.spawn_sfx, 0.08)
