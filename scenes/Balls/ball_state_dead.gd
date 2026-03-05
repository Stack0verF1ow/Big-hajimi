class_name BallStateDead
extends BallState

func _enter_tree() -> void:
	# 立即关闭视觉和碰撞
	ball.visible = false
	ball.collision.set_deferred("disabled", true)

	# 只有最大球消除时才播音效（由 Game 通过 state_data 标记）
	if state_data.play_merge_sfx:
		SoundPlayer.play_sfx("merge_max")

	# 音效是全局播放的，Ball 节点可以立即释放
	ball.call_deferred("queue_free")
