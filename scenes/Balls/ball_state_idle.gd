class_name BallStateIdle
extends BallState

func _ready() -> void:
	ball.contact_monitor = true
	ball.max_contacts_reported = 4
	ball.body_entered.connect(_on_body_entered)

func _enter_tree() -> void:
	# 播放生成音效
	var sound = ball._pending_data.get("spawn_sound")
	if sound:
		ball.sfx_player.stream = sound
		ball.sfx_player.play()
	

func _on_body_entered(body: Node) -> void:
	# ① 必须是 Ball
	if not body is Ball:
		return

	# ② 必须是同类型水果
	if body.ball_type != ball.ball_type:
		return

	# 携带碰撞对象，进入 MERGING 状态
	var data := BallStateData.build().set_contact_ball(body)
	transition_state(Ball.State.MERGING, data)
