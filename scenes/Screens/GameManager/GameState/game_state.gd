class_name GameState
extends Node

signal state_transition_requested(new_state: GameManager.State, data: GameStateData)

var game_manager: GameManager = null
var state_data:   GameStateData = GameStateData.new()

func setup(context_manager: GameManager, context_data: GameStateData = GameStateData.new()) -> void:
	game_manager = context_manager
	state_data   = context_data

func transition_state(new_state: GameManager.State, data: GameStateData = GameStateData.new()) -> void:
	state_transition_requested.emit(new_state, data)
