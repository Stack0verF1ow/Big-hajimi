class_name GameStateData

var final_score: int = 0

static func build() -> GameStateData:
	return GameStateData.new()

func set_final_score(value: int) -> GameStateData:
	final_score = value
	return self
