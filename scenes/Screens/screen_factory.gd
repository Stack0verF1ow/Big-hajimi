class_name ScreenFactory

var _screens: Dictionary

func _init() -> void:
	_screens = {
		Game.ScreenType.MAIN_MENU : preload("res://scenes/Screens/MainMenu/main_menu_screen.tscn"),
		Game.ScreenType.IN_GAME   : preload("res://scenes/Screens/Game/game_screen.tscn"),
	}


func get_fresh_screen(screen: Game.ScreenType) -> Screen:
	assert(_screens.has(screen), "ScreenFactory: 未注册的屏幕 → " + str(screen))
	return _screens[screen].instantiate() as Screen
