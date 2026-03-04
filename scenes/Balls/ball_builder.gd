class_name BallBuilder

var _ball_scene = preload("res://scenes/Balls/ball.tscn")
var _data = {}

func _init():
	reset()

func reset():
	_data = {
		"type": 0,
		"index": 0,
		"texture": null,
		"radius": 50.0, # 默认半径
		"score": 10,
		"sound": null
	}
	return self

func set_basic_info(type: int, score: int, index: int):  # ← 新增 index 参数
	_data["type"]  = type
	_data["score"] = score
	_data["index"] = index   # ← 透传下标
	return self

func set_physics(radius: float):
	_data["radius"] = radius
	return self

func set_assets(tex_path: String, spawn_sfx_path: String = "", merge_sfx_path: String = "") -> BallBuilder:
	_data["texture"]   = load(tex_path)
	if spawn_sfx_path != "":
		_data["spawn_sound"] = load(spawn_sfx_path)
	if merge_sfx_path != "":
		_data["merge_sound"] = load(merge_sfx_path)
	return self

func build() -> Ball:
	var instance = _ball_scene.instantiate()
	instance.setup(_data)
	return instance
