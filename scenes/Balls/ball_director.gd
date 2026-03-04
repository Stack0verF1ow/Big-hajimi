class_name BallDirector

var builder: BallBuilder
var _config_data: Array = []


func _init(p_builder: BallBuilder):
	builder = p_builder

# 新增：接收数据的方法，符合依赖注入思想
func load_data(data: Array):
	_config_data = data

# 根据配置索引创建水果
func create_ball_by_index(index: int) -> Ball:
	if index < 0 or index >= _config_data.size():
		push_error("水果索引越界")
		return null
		
	var config = _config_data[index]
	
	# 使用建造者模式组装从数据读取的信息
	return builder.reset()\
		.set_basic_info(config["id"], config["score"], index)\
		.set_physics(config.get("radius", 50.0))\
		.set_assets(config["texture"], config.get("spawn_sfx", ""), config.get("merge_sfx", ""))\
		.build()
