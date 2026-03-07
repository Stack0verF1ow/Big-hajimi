class_name MainMenuScreen
extends Screen

# ── 主菜单按钮组 ─────────────────────────────────────────────
@onready var detail_meun:    VBoxContainer  = %DetailMeun
@onready var start_button:    Button         = %Start
@onready var continue_button: Button         = %Continue
@onready var settings_button: Button         = %Settings
@onready var costom_button:   Button         = %Costom

# ── 设置面板 ─────────────────────────────────────────────────
@onready var backdrop:        ColorRect      = %Backdrop
@onready var game_settings:   MarginContainer = %GameSettings
@onready var exit_button:     Button         = %ExitButton
@onready var music_slider:    HScrollBar     = %MusicVolume
@onready var sound_slider:    HScrollBar     = %SoundVolume

var _bgm_bus_idx:    int
var _sfx_bus_idx:    int
var _sfx_hint_timer: SceneTreeTimer   # 防抖：停止拖动后才播提示音

func _ready() -> void:
	_bgm_bus_idx = AudioServer.get_bus_index("BGM")
	_sfx_bus_idx = AudioServer.get_bus_index("SFX")
	_init_settings_panel()
	_connect_signals()

# ── 初始化 ───────────────────────────────────────────────────

func _init_settings_panel() -> void:
	# 修复①：Backdrop 颜色在代码里保证，不依赖编辑器默认值
	backdrop.color   = Color(0.0, 0.0, 0.0, 0.6)
	backdrop.visible = false

	# 修复②：明确设置滑块范围，否则 max_value 默认 0 导致无法拖动
	for slider: HScrollBar in [music_slider, sound_slider]:
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step      = 0.01

	# 加载设置并同步到滑块和 AudioServer
	var settings := DataLoader.load_settings()
	music_slider.value = settings.get("music_volume", 0.8)
	sound_slider.value = settings.get("sound_volume", 0.8)
	_apply_music_volume(music_slider.value)
	_apply_sound_volume(sound_slider.value)

	game_settings.visible = false

func _connect_signals() -> void:
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_settings_pressed)
	music_slider.value_changed.connect(_apply_music_volume)
	sound_slider.value_changed.connect(_on_sound_slider_changed)

# ── 按钮回调 ─────────────────────────────────────────────────

func _on_start_pressed() -> void:
	SoundPlayer.play_ui("ui_click")
	transition_screen(Game.ScreenType.IN_GAME)

func _on_settings_pressed() -> void:
	SoundPlayer.play_ui("ui_click")
	_open_settings()

func _on_exit_settings_pressed() -> void:
	SoundPlayer.play_ui("ui_click")
	_save_and_close_settings()

# ── 音量滑块回调 ─────────────────────────────────────────────

func _apply_music_volume(value: float) -> void:
	AudioServer.set_bus_volume_db(_bgm_bus_idx, linear_to_db(value))

func _apply_sound_volume(value: float) -> void:
	AudioServer.set_bus_volume_db(_sfx_bus_idx, linear_to_db(value))

# 修复③：停止拖动 0.4 秒后播一次提示音，避免拖动时连续触发
func _on_sound_slider_changed(value: float) -> void:
	_apply_sound_volume(value)
	# 取消上一个还未触发的计时器
	if is_instance_valid(_sfx_hint_timer):
		if _sfx_hint_timer.timeout.is_connected(_play_sound_hint):
			_sfx_hint_timer.timeout.disconnect(_play_sound_hint)
	_sfx_hint_timer = get_tree().create_timer(0.4)
	_sfx_hint_timer.timeout.connect(_play_sound_hint, CONNECT_ONE_SHOT)

func _play_sound_hint() -> void:
	SoundPlayer.play_ui("ui_click")

# ── 设置面板开关 ─────────────────────────────────────────────

func _open_settings() -> void:
	detail_meun.visible  = false
	backdrop.modulate.a   = 0.0
	backdrop.visible      = true
	game_settings.visible = true

	var tween := create_tween()
	tween.tween_property(backdrop, "modulate:a", 1.0, 0.2)

func _save_and_close_settings() -> void:
	DataWriter.save_settings({
		"music_volume": music_slider.value,
		"sound_volume": sound_slider.value,
	})

	var tween := create_tween()
	tween.tween_property(backdrop, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func() -> void:
		backdrop.visible      = false
		game_settings.visible = false
		detail_meun.visible  = true
	)

func get_bgm_context() -> String:
	return "menu"
