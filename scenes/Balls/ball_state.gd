class_name BallState
extends Node

signal state_transition_requested( new_state: Ball.State, data: BallStateData )

var ball : Ball = null
var state_data := BallStateData.new()

func setup( context_ball: Ball, context_ball_state_data: BallStateData = BallStateData.new()) -> void:
	ball = context_ball
	state_data = context_ball_state_data

func transition_state(new_state: Ball.State, data: BallStateData = BallStateData.new()) -> void:
	state_transition_requested.emit(new_state, data)
