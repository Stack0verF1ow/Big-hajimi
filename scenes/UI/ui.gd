class_name UI
extends CanvasLayer

# ── 游戏 HUD ─────────────────────────────────────────────────
@onready var score_label:       Label          = %ScoreLabel
@onready var pause_button:      Button         = %PauseButton
@onready var skill_container:   HBoxContainer  = %SkillContainer
@onready var preview_container: HBoxContainer  = %PreviewContainer
@onready var preview_1: TextureRect = %Preview1
@onready var preview_2: TextureRect = %Preview2

# ── 暂停面板 ─────────────────────────────────────────────────
@onready var pause_ui:        MarginContainer  = %PauseUI
@onready var backdrop:        ColorRect        = %Backdrop
@onready var home_button:     Button           = %HomeButton
@onready var countine_button: Button           = %CountineButton
@onready var settings_button: Button           = %SettingsButton
@onready var helper_button:   Button           = %HelperButton

# GameScreen 监听此信号路由到 transition_screen
signal home_pressed

func setup() -> void:
	backdrop.color        = Color(0.0, 0.0, 0.0, 0.6)
	backdrop.visible      = false
	pause_ui.visible      = false
	backdrop.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_ui.process_mode = Node.PROCESS_MODE_ALWAYS

	# 全部走 GameBus
	GameBus.score_changed.connect(_on_score_changed)
	GameBus.game_continued.connect(hide_pause)

	pause_button.pressed.connect(_on_pause_pressed)

	for btn: Button in [home_button, countine_button, settings_button, helper_button]:
		btn.process_mode = Node.PROCESS_MODE_ALWAYS
	countine_button.pressed.connect(_on_continue_pressed)
	home_button.pressed.connect(_on_home_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	helper_button.pressed.connect(_on_helper_pressed)

# ── HUD 更新 ─────────────────────────────────────────────────

func on_queue_preview_updated(texture_paths: Array[String]) -> void:
	var backgrounds: Array[Node] = preview_container.get_children()
	for i in min(backgrounds.size(), texture_paths.size()):
		var slot := backgrounds[i].get_child(0) as TextureRect
		if slot:
			slot.texture = load(texture_paths[i])
		
func _on_score_changed(value: int) -> void:
	score_label.text = str(value)

# ── 暂停面板 ─────────────────────────────────────────────────

func show_pause() -> void:
	backdrop.modulate.a = 0.0
	backdrop.visible    = true
	pause_ui.modulate.a = 0.0
	pause_ui.visible    = true
	var tween := create_tween().set_parallel(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(backdrop, "modulate:a", 1.0, 0.2)
	tween.tween_property(pause_ui, "modulate:a", 1.0, 0.2)

func hide_pause() -> void:
	# 恢复暂停按钮为弹起状态
	pause_button.button_pressed = false
	var tween := create_tween().set_parallel(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(backdrop, "modulate:a", 0.0, 0.15)
	tween.tween_property(pause_ui, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func() -> void:
		backdrop.visible = false
		pause_ui.visible = false
	).set_delay(0.15)

# ── 结算 ─────────────────────────────────────────────────────

func show_game_over(final_score: int) -> void:
	print("Game Over — 最终得分：", final_score)  # TODO: 结算 UI

# ── 按钮回调 ─────────────────────────────────────────────────

func _on_pause_pressed() -> void:
	SoundPlayer.play_ui("ui_click")
	show_pause()
	GameBus.game_to_be_pause.emit()

func _on_continue_pressed() -> void:
	SoundPlayer.play_ui("ui_click")
	GameBus.game_to_be_continue.emit()
	# hide_pause 由 GameBus.game_continued 触发（GameStatePause._exit_tree emit）

func _on_home_pressed() -> void:
	SoundPlayer.play_ui("ui_click")
	var tween := create_tween().set_parallel(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(backdrop, "modulate:a", 0.0, 0.15)
	tween.tween_property(pause_ui, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func() -> void:
		backdrop.visible = false
		pause_ui.visible = false
		home_pressed.emit()   # → GameScreen → transition_screen(MAIN_MENU)
	).set_delay(0.15)

func _on_settings_pressed() -> void:
	SoundPlayer.play_ui("ui_click")
	# TODO: 游戏内设置

func _on_helper_pressed() -> void:
	SoundPlayer.play_ui("ui_click")
	# TODO: 帮助说明
