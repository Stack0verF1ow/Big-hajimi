class_name GameStatePause
extends GameState

func _enter_tree() -> void:
	get_tree().paused = true
	game_manager.process_mode = Node.PROCESS_MODE_ALWAYS
	GameBus.game_to_be_continue.connect(_on_game_to_be_continue)

func _exit_tree() -> void:
	get_tree().paused = false
	game_manager.process_mode = Node.PROCESS_MODE_INHERIT
	GameBus.game_to_be_continue.disconnect(_on_game_to_be_continue)
	GameBus.game_continued.emit()   # → UI.hide_pause()

func _on_game_to_be_continue() -> void:
	transition_state(GameManager.State.IN_PLAY)
