class_name BallBuilder

var _ball_scene = preload("res://scenes/Balls/ball.tscn")
var _data := {}

func _init() -> void:
	reset()

func reset() -> BallBuilder:
	_data = {
		"type":             0,
		"index":            0,
		"radius":           50.0,
		"score":            0,
		"texture":          null,
		"spawn_sfx":        null,
		"spawn_sfx_chance": 0.0,
	}
	return self

func set_basic_info(type: int, score: int, index: int) -> BallBuilder:
	_data["type"]  = type
	_data["score"] = score
	_data["index"] = index
	return self

func set_physics(radius: float) -> BallBuilder:
	_data["radius"] = radius
	return self

func set_assets(tex_path: String, spawn_sfx_path: String = "", spawn_sfx_chance: float = 0.0) -> BallBuilder:
	_data["texture"]          = load(tex_path)
	_data["spawn_sfx_chance"] = spawn_sfx_chance
	if spawn_sfx_path != "":
		_data["spawn_sfx"] = load(spawn_sfx_path)
	return self

func build() -> Ball:
	var instance := _ball_scene.instantiate() as Ball
	instance.setup(_data)
	return instance
