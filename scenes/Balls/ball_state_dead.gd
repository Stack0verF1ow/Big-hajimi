class_name BallStateDead
extends BallState

func _enter_tree() -> void:
	ball.visible = false
	ball.collision.set_deferred("disabled", true)
	
	# 只有最大球消除时才播音效
	var sound = ball._pending_data.get("merge_sound")
	if sound and state_data.play_merge_sfx:
		ball.sfx_player.stream = sound
		ball.sfx_player.play()
		ball.sfx_player.finished.connect(func(): ball.call_deferred("queue_free"))
	else:
		ball.call_deferred("queue_free")
