# DataLoader.gd
class_name DataLoader

# 专注读取文件和解析 JSON
static func load_ball_config(path: String) -> Array:
	if not FileAccess.file_exists(path):
		push_error("配置文件不存在: " + path)
		return []

	var file = FileAccess.open(path, FileAccess.READ)
	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		var data = json.get_data()
		# 确保返回的是数组
		if data is Dictionary and data.has("balls"):
			return data["balls"]
		else:
			push_error("JSON 结构不正确")
			return []
	else:
		push_error("JSON 解析错误: " + json.get_error_message())
		return []
