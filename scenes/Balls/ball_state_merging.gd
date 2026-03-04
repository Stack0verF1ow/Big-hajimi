class_name BallStateMerging
extends BallState

func _enter_tree() -> void:
	# 冻结自身，阻止继续参与物理碰撞
	ball.set_deferred("freeze", true)

	# ID 仲裁：只有 ID 较小的一方通知 Game 处理合成
	# 两球都会进入此状态，但信号只发一次
	var other := state_data.contact_ball
	if not is_instance_valid(other):
		return
	if ball.get_instance_id() < other.get_instance_id():
		ball.want_to_merge.emit(ball, other)
