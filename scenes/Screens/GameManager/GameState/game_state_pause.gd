class_name GameStatePause
extends GameState

func _enter_tree() -> void:
	get_tree().paused = true
	game_manager.ui.show_pause()
	# PROCESS_MODE_ALWAYS 保证 GameManager 自身在暂停时仍能响应恢复信号
	game_manager.process_mode = Node.PROCESS_MODE_ALWAYS
	GameBus.resume_requested.connect(_on_resume_requested)

func _exit_tree() -> void:
	get_tree().paused = false
	game_manager.process_mode = Node.PROCESS_MODE_INHERIT
	GameBus.resume_requested.disconnect(_on_resume_requested)

func _on_resume_requested() -> void:
	transition_state(GameManager.State.IN_PLAY)
