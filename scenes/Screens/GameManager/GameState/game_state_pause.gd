class_name GameStatePause
extends GameState

func _enter_tree() -> void:
	get_tree().paused = true
	game_manager.process_mode = Node.PROCESS_MODE_ALWAYS

func _exit_tree() -> void:
	get_tree().paused = false
	game_manager.process_mode = Node.PROCESS_MODE_INHERIT
