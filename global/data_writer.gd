class_name DataWriter

# ── 用户设置 ────────────────────────────────────────────────
static func save_settings(settings: Dictionary) -> void:
	var file := FileAccess.open(DataLoader.SETTINGS_PATH, FileAccess.WRITE)
	if not file:
		push_error("DataWriter: 无法写入设置文件 → " + DataLoader.SETTINGS_PATH)
		return
	file.store_string(JSON.stringify(settings, "\t"))
