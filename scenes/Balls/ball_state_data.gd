class_name BallStateData

var contact_ball: Ball
var play_merge_sfx: bool = false   

static func build() -> BallStateData:
	return BallStateData.new()

func set_contact_ball(context_contact_ball: Ball) -> BallStateData:
	contact_ball = context_contact_ball
	return self

func set_play_merge_sfx(value: bool) -> BallStateData:   
	play_merge_sfx = value
	return self
