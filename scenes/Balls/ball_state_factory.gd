class_name BallStateFactory
extends Node

var states : Dictionary

func _init() -> void:
	states = {
		Ball.State.IDLE : BallStateIdle,
		Ball.State.MERGING : BallStateMerging,
		Ball.State.DEAD : BallStateDead,
	}

func get_fresh_state(state: Ball.State) -> BallState:
	assert(states.has(state), "state don't exist!")
	return states.get(state).new()
