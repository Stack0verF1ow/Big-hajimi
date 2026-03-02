class_name BallBuilder

var _ball_scene = preload("res://scenes/Balls/ball.tscn")
var _data = {}

func _init():
	reset()

func reset():
	_data = {
		"type": 0,
		"texture": null,
		"radius": 50.0, # 默认半径
		"score": 10,
		"sound": null
	}
	return self

func set_basic_info(type: int, score: int):
	_data["type"] = type
	_data["score"] = score
	return self

func set_physics(radius: float):
	_data["radius"] = radius
	return self

func set_assets(tex_path: String, sfx_path: String = ""):
	_data["texture"] = load(tex_path)
	# 确保这里存入了 scale，即便默认是 1.0
	_data["scale"] = _data.get("scale", 1.0) 
	if sfx_path != "":
		_data["sound"] = load(sfx_path)
	return self

func build() -> Ball:
	var instance = _ball_scene.instantiate()
	instance.setup(_data)
	return instance
