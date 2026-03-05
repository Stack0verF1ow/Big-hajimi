class_name GameStateFactory

var _states: Dictionary

func _init() -> void:
	_states = {
		GameManager.State.IN_PLAY   : GameStateInPlay,
		GameManager.State.GAME_OVER : GameStateGameOver,
		GameManager.State.PAUSE     : GameStatePause,
	}

func get_fresh_state(state: GameManager.State) -> GameState:
	assert(_states.has(state), "GameStateFactory: 未注册的状态 → " + str(state))
	return _states[state].new()
