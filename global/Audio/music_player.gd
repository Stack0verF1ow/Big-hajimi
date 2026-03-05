extends Node

const FADE_DURATION := 0.8

const BGM_DIRS: Dictionary = {
	"menu" : "res://assets/audio/bgm/Menu/",
	"game" : "res://assets/audio/bgm/InGame/",
}

# 支持的音频格式
const AUDIO_EXTENSIONS := ["mp3", "ogg", "wav"]

var _current_player: AudioStreamPlayer
var _next_player:    AudioStreamPlayer
var _tween:          Tween

# 每个场景的曲目列表：key → Array[AudioStream]
var _playlists:      Dictionary = {}
# 当前播放列表的 key
var _current_context: String = ""
# 上一首的索引，用于避免连续播放同一首
var _last_index: int = -1

func _ready() -> void:
	_current_player = _make_player()
	_next_player    = _make_player()
	_scan_all_dirs()

# ── 公开接口 ─────────────────────────────────────────────────

func play_menu_music() -> void:
	_play_context("menu")

func play_game_music() -> void:
	_play_context("game")

func stop_music() -> void:
	_kill_tween()
	if _current_player.finished.is_connected(_on_track_finished):
		_current_player.finished.disconnect(_on_track_finished)
	_fade_out(_current_player, true)
	_current_context = ""
	_last_index = -1

# ── 内部：场景切换与随机播放 ─────────────────────────────────

func _play_context(context: String) -> void:
	# 已在当前场景则不切换（继续播当前曲）
	if _current_context == context and _current_player.playing:
		return
	_current_context = context
	_last_index = -1
	_play_next()

func _play_next() -> void:
	var playlist: Array = _playlists.get(_current_context, [])
	if playlist.is_empty():
		push_warning("MusicPlayer: 播放列表为空 → " + _current_context)
		return

	var index := _pick_random_index(playlist.size())
	_last_index = index
	var stream: AudioStream = playlist[index]

	# 断开旧的 finished 连接，防止重复注册
	if _current_player.finished.is_connected(_on_track_finished):
		_current_player.finished.disconnect(_on_track_finished)

	if not _current_player.playing:
		_current_player.stream = stream
		_current_player.volume_db = linear_to_db(0.0)
		_current_player.play()
		_fade_in(_current_player)
	else:
		_crossfade(stream)

	# 曲子播完后自动播下一首
	_current_player.finished.connect(_on_track_finished, CONNECT_ONE_SHOT)

func _on_track_finished() -> void:
	# 确保仍在同一场景才继续
	if _current_context != "":
		_play_next()

# 随机选取，避免和上一首重复（曲库只有一首时不处理）
func _pick_random_index(size: int) -> int:
	if size == 1:
		return 0
	var index := randi() % size
	while index == _last_index:
		index = randi() % size
	return index

# ── 内部：目录扫描 ───────────────────────────────────────────

func _scan_all_dirs() -> void:
	for key in BGM_DIRS:
		_playlists[key] = _scan_dir(BGM_DIRS[key])
		print("MusicPlayer: [%s] 加载 %d 首" % [key, _playlists[key].size()])

func _scan_dir(dir_path: String) -> Array:
	var result: Array = []
	var dir := DirAccess.open(dir_path)
	if not dir:
		push_warning("MusicPlayer: 无法打开目录 → " + dir_path)
		return result

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			var ext := file_name.get_extension().to_lower()
			if ext in AUDIO_EXTENSIONS:
				var full_path := dir_path + file_name
				var stream := load(full_path) as AudioStream
				if stream:
					result.append(stream)
		file_name = dir.get_next()
	dir.list_dir_end()

	result.shuffle()   # 初始打乱顺序，增加随机感
	return result

# ── 内部：淡变逻辑（与之前相同）─────────────────────────────

func _crossfade(stream: AudioStream) -> void:
	_kill_tween()
	if _current_player.finished.is_connected(_on_track_finished):
		_current_player.finished.disconnect(_on_track_finished)

	_next_player.stream = stream
	_next_player.volume_db = linear_to_db(0.0)
	_next_player.play()

	_tween = create_tween().set_parallel(true)
	_tween.tween_method(
		func(v: float): _current_player.volume_db = linear_to_db(v),
		1.0, 0.0, FADE_DURATION
	)
	_tween.tween_method(
		func(v: float): _next_player.volume_db = linear_to_db(v),
		0.0, 1.0, FADE_DURATION
	)
	_tween.tween_callback(_on_crossfade_finished).set_delay(FADE_DURATION)

func _fade_in(player: AudioStreamPlayer) -> void:
	_kill_tween()
	_tween = create_tween()
	_tween.tween_method(
		func(v: float): player.volume_db = linear_to_db(v),
		0.0, 1.0, FADE_DURATION
	)

func _fade_out(player: AudioStreamPlayer, stop_after: bool = false) -> void:
	_kill_tween()
	_tween = create_tween()
	_tween.tween_method(
		func(v: float): player.volume_db = linear_to_db(v),
		1.0, 0.0, FADE_DURATION
	)
	if stop_after:
		_tween.tween_callback(player.stop)

func _on_crossfade_finished() -> void:
	_current_player.stop()
	var tmp         = _current_player
	_current_player = _next_player
	_next_player    = tmp
	# 交换后把 finished 信号迁移到新的 current
	if _next_player.finished.is_connected(_on_track_finished):
		_next_player.finished.disconnect(_on_track_finished)
	_current_player.finished.connect(_on_track_finished, CONNECT_ONE_SHOT)

func _kill_tween() -> void:
	if is_instance_valid(_tween):
		_tween.kill()

func _make_player() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = "BGM"
	add_child(p)
	return p
