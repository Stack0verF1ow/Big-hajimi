# DataLoader.gd
class_name DataLoader

static func load_ball_config(path: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	if not FileAccess.file_exists(path):
		push_error("配置文件不存在: " + path)
		return result

	var file = FileAccess.open(path, FileAccess.READ)
	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		push_error("JSON 解析错误: " + json.get_error_message())
		return result

	var data = json.get_data()
	if not (data is Dictionary and data.has("balls")):
		push_error("JSON 结构不正确")
		return result

	# JSON 解析结果是无类型 Array，需逐条 assign 才能转为 Array[Dictionary]
	for item in data["balls"]:
		result.append(item as Dictionary)

	return result
