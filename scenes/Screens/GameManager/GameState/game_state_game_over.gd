class_name GameStateGameOver
extends GameState

func _enter_tree() -> void:
	game_manager.launcher_manager.set_process(false)
	GameBus.game_over.emit(state_data.final_score)   # → UI.show_game_over()
