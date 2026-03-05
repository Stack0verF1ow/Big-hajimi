class_name GameStateGameOver
extends GameState

func _enter_tree() -> void:
	# 禁用发射器，防止继续操作
	game_manager.launcher_manager.set_process(false)

	# 通知 UI 显示结算画面，携带最终分数
	game_manager.ui.show_game_over(state_data.final_score)
