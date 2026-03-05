class_name BallDirector

var builder:      BallBuilder
var _config_data: Array[Dictionary] = []

func _init(p_builder: BallBuilder) -> void:
	builder = p_builder

func load_data(data: Array[Dictionary]) -> void:
	_config_data = data

func create_ball_by_index(index: int) -> Ball:
	if index < 0 or index >= _config_data.size():
		push_error("BallDirector: 索引越界 → " + str(index))
		return null

	var config := _config_data[index]
	return builder.reset()\
		.set_basic_info(config["id"], config["score"], index)\
		.set_physics(config.get("radius", 50.0))\
		.set_assets(
			config["texture"],
			config.get("spawn_sfx", ""),
			config.get("spawn_sfx_chance", 0.0)
		)\
		.build()
