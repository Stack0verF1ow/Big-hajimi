class_name DataLoader

const SETTINGS_PATH    := "user://settings.json"
const SETTINGS_DEFAULT := {
	"music_volume": 0.8,
	"sound_volume": 0.8,
}

# ── Ball 配置 ────────────────────────────────────────────────
static func load_ball_config(path: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not FileAccess.file_exists(path):
		push_error("配置文件不存在: " + path)
		return result

	var file        := FileAccess.open(path, FileAccess.READ)
	var json_string := file.get_as_text()
	var json        := JSON.new()

	if json.parse(json_string) != OK:
		push_error("JSON 解析错误: " + json.get_error_message())
		return result

	var data = json.get_data()
	if not (data is Dictionary and data.has("balls")):
		push_error("JSON 结构不正确")
		return result

	for item in data["balls"]:
		result.append(item as Dictionary)
	return result

# ── 用户设置 ────────────────────────────────────────────────
static func load_settings() -> Dictionary:
	# 第一次运行时 user:// 下还没有文件，返回默认值
	if not FileAccess.file_exists(SETTINGS_PATH):
		return SETTINGS_DEFAULT.duplicate()

	var file        := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	var json_string := file.get_as_text()
	var json        := JSON.new()

	if json.parse(json_string) != OK:
		push_warning("设置文件解析失败，使用默认值")
		return SETTINGS_DEFAULT.duplicate()

	var data = json.get_data()
	if not data is Dictionary:
		return SETTINGS_DEFAULT.duplicate()

	# 用默认值补全缺失字段，保证向前兼容
	var result := SETTINGS_DEFAULT.duplicate()
	for key in data:
		result[key] = data[key]
	return result
