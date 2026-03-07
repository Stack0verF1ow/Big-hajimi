class_name UI
extends CanvasLayer

# ── 游戏 HUD ─────────────────────────────────────────────────
@onready var score_label:       Label           = %ScoreLabel
@onready var pause_button:      Button          = %PauseButton
@onready var skill_container:   HBoxContainer   = %SkillContainer
@onready var preview_container: HBoxContainer   = %PreviewContainer

# ── 暂停面板 ─────────────────────────────────────────────────
@onready var pause_ui:          MarginContainer = %PauseUI
@onready var backdrop:          ColorRect       = %Backdrop
@onready var home_button:       Button          = %HomeButton
@onready var countine_button:   Button          = %CountineButton
@onready var settings_button:   Button          = %SettingsButton
@onready var helper_button:     Button          = %HelperButton

# GameScreen 连接此信号，调用 transition_screen 切回主菜单
signal home_pressed

var _config_data: Array[Dictionary] = []

func setup(config_data: Array[Dictionary]) -> void:
	_config_data = config_data

	backdrop.color        = Color(0.0, 0.0, 0.0, 0.6)
	backdrop.visible      = false
	pause_ui.visible      = false
	# 暂停时仍需处理，否则 Tween 会停摆
	backdrop.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_ui.process_mode = Node.PROCESS_MODE_ALWAYS

	GameBus.score_changed.connect(_on_score_changed)
	GameBus.queue_changed.connect(on_queue_changed)

	pause_button.pressed.connect(_on_pause_pressed)

	# 暂停面板按钮在游戏暂停时仍需响应
	for btn: Button in [home_button, countine_button, settings_button, helper_button]:
		btn.process_mode = Node.PROCESS_MODE_ALWAYS
	countine_button.pressed.connect(_on_continue_pressed)
	home_button.pressed.connect(_on_home_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	helper_button.pressed.connect(_on_helper_pressed)

# ── HUD 更新 ─────────────────────────────────────────────────

func on_queue_changed(indices: Array[int]) -> void:
	var slots: Array[Node] = preview_container.get_children()
	for i in slots.size():
		var queue_pos := i + 1
		if queue_pos >= indices.size():
			break
		var config: Dictionary = _config_data[indices[queue_pos]]
		var slot: TextureRect = slots[i]
		slot.texture = load(config["texture"])

func _on_score_changed(value: int) -> void:
	score_label.text = str(value)

# ── 暂停面板显示 / 隐藏 ──────────────────────────────────────

func show_pause() -> void:
	backdrop.modulate.a = 0.0
	backdrop.visible    = true
	pause_ui.modulate.a = 0.0
	pause_ui.visible    = true
	var tween := create_tween().set_parallel(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)  # 场景树暂停时仍继续执行
	tween.tween_property(backdrop, "modulate:a", 1.0, 0.2)
	tween.tween_property(pause_ui, "modulate:a", 1.0, 0.2)

func hide_pause() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(backdrop, "modulate:a", 0.0, 0.15)
	tween.tween_property(pause_ui, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func() -> void:
		backdrop.visible = false
		pause_ui.visible = false
	).set_delay(0.15)

# ── 游戏结算 ─────────────────────────────────────────────────

func show_game_over(final_score: int) -> void:
	# TODO: 显示结算画面
	print("Game Over — 最终得分：", final_score)

# ── 按钮回调 ─────────────────────────────────────────────────

func _on_pause_pressed() -> void:
	SoundPlayer.play_ui("ui_click")
	GameBus.pause_requested.emit()  # GameStatePause._enter_tree() 会调用 show_pause()

func _on_continue_pressed() -> void:
	SoundPlayer.play_ui("ui_click")
	hide_pause()
	GameBus.resume_requested.emit()

func _on_home_pressed() -> void:
	SoundPlayer.play_ui("ui_click")
	# 先淡出，动画结束后通知 GameScreen 切换屏幕
	var tween := create_tween().set_parallel(true)
	tween.tween_property(backdrop, "modulate:a", 0.0, 0.15)
	tween.tween_property(pause_ui, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func() -> void:
		backdrop.visible = false
		pause_ui.visible = false
		get_tree().paused = false   # 恢复物理，防止切换后场景树仍处于暂停
		home_pressed.emit()         # ← 只发信号，不做路由决策
	).set_delay(0.15)

func _on_settings_pressed() -> void:
	SoundPlayer.play_ui("ui_click")
	# TODO: 游戏内设置面板

func _on_helper_pressed() -> void:
	SoundPlayer.play_ui("ui_click")
	# TODO: 帮助说明
