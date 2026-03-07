class_name Game
extends Node

enum ScreenType {
	MAIN_MENU,
	IN_GAME,
}

var _current_screen: Screen = null
var _screen_factory := ScreenFactory.new()

func _ready() -> void:
	# Autoload 在 _ready 里初始化，此时场景树已就绪可以 add_child
	_switch_screen(ScreenType.MAIN_MENU)

func _switch_screen(screen: ScreenType, data: ScreenData = ScreenData.new()) -> void:
	# 清理旧屏幕
	if is_instance_valid(_current_screen):
		_current_screen.screen_transition_requested.disconnect(_on_screen_transition_requested)
		_current_screen.queue_free()

	# 创建新屏幕、注入上下文、连接信号后再挂载
	_current_screen = _screen_factory.get_fresh_screen(screen)
	_current_screen.setup(self, data)
	_current_screen.screen_transition_requested.connect(_on_screen_transition_requested)
	add_child(_current_screen)

func _on_screen_transition_requested(new_screen: ScreenType, data: ScreenData) -> void:
	_switch_screen(new_screen, data)
