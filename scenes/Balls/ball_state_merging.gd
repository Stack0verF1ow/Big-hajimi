class_name BallStateMerging
extends BallState

func _enter_tree() -> void:
	ball.set_deferred("freeze", true)

	var other := state_data.contact_ball
	if not is_instance_valid(other):
		return

	# ID 仲裁：只有 ID 较小的一方通知 Game 处理合成
	if ball.get_instance_id() < other.get_instance_id():
		ball.want_to_merge.emit(ball, other)
