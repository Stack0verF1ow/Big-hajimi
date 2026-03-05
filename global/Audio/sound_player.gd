extends Node

# ── 公共音效预加载表（各球独有的 spawn_sfx 不在此处）────────
const SOUNDS: Dictionary = {
	"drop"         : "res://assets/sfx/drop.wav",
	"merge_normal" : "res://assets/sfx/merge_normal.wav",
	"merge_max"    : "res://assets/sfx/merge_max.wav",
	"ui_click"     : "res://assets/sfx/ui_click.wav",
}

const COMBO_PITCH_BASE := 1.0
const COMBO_PITCH_STEP := 0.05

var _sfx_player: AudioStreamPlayer
var _ui_player:  AudioStreamPlayer
var _streams:    Dictionary = {}

func _ready() -> void:
	_sfx_player = _make_player("SFX", 15, PROCESS_MODE_INHERIT)
	_ui_player  = _make_player("SFX",  5, PROCESS_MODE_ALWAYS)
	_preload_sounds()

# ── 公开接口 ─────────────────────────────────────────────────

# 按名称播放公共音效
func play_sfx(sound_name: String, pitch_variance: float = 0.0) -> void:
	var stream := _get_stream(sound_name)
	if not stream:
		return
	_play_on_sfx_player(stream, _random_pitch(pitch_variance))

# 直接传入 AudioStream 播放（供 BallStateIdle 等使用球独有的生成音效）
func play_sfx_stream(stream: AudioStream, pitch_variance: float = 0.0) -> void:
	if not stream:
		return
	_play_on_sfx_player(stream, _random_pitch(pitch_variance))

# 播放 UI 音效（暂停时仍有效）
func play_ui(sound_name: String) -> void:
	var stream := _get_stream(sound_name)
	if not stream:
		return
	_ui_player.stream = stream
	_ui_player.pitch_scale = 1.0
	_ui_player.play()

# 连击音效：等级越高音调越高
func play_merge_combo(level: int) -> void:
	var stream := _get_stream("merge_normal")
	if not stream:
		return
	_sfx_player.stream = stream
	_sfx_player.pitch_scale = COMBO_PITCH_BASE + (level - 1) * COMBO_PITCH_STEP
	_sfx_player.play()

# ── 内部实现 ─────────────────────────────────────────────────

func _play_on_sfx_player(stream: AudioStream, pitch: float) -> void:
	_sfx_player.stream = stream
	_sfx_player.pitch_scale = pitch
	_sfx_player.play()

func _preload_sounds() -> void:
	for key in SOUNDS:
		var path: String = SOUNDS[key]
		if ResourceLoader.exists(path):
			_streams[key] = load(path)
		else:
			push_warning("SoundPlayer: 找不到音频资源 → " + path)

func _get_stream(sound_name: String) -> AudioStream:
	if not _streams.has(sound_name):
		push_warning("SoundPlayer: 未知音效名称 → " + sound_name)
		return null
	return _streams[sound_name]

func _random_pitch(variance: float) -> float:
	if variance <= 0.0:
		return 1.0
	return 1.0 + randf_range(-variance, variance)

@warning_ignore("shadowed_variable_base_class")
func _make_player(bus: String, polyphony: int, process_mode: ProcessMode) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus           = bus
	p.max_polyphony = polyphony
	p.process_mode  = process_mode
	add_child(p)
	return p
