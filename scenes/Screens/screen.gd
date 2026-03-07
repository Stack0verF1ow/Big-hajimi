class_name Screen
extends Node

signal screen_transition_requested(new_screen: Game.ScreenType, data: ScreenData)

var game:        Game       = null
var screen_data: ScreenData = null

func _enter_tree() -> void:
	# 每个子类覆盖 get_bgm_context() 返回对应的音乐场景
	var ctx := get_bgm_context()
	match ctx:
		"menu": MusicPlayer.play_menu_music()
		"game": MusicPlayer.play_game_music()
		"":     pass   # 此屏幕无 BGM

func setup(context_game: Game, context_data: ScreenData) -> void:
	game        = context_game
	screen_data = context_data

func transition_screen(new_screen: Game.ScreenType, data: ScreenData = ScreenData.new()) -> void:
	screen_transition_requested.emit(new_screen, data)

# ── 子类覆盖：返回 "menu" / "game" / "" ─────────────────────
func get_bgm_context() -> String:
	return ""
