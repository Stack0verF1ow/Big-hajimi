class_name GameScreen
extends Screen

@onready var launcher_manager: LauncherManager = %LauncherManager
@onready var ui:               UI              = %UI

func _ready() -> void:
	GameManager.register_scene(ui, launcher_manager, self)
	# UI 只负责发出 home_pressed 信号，由 GameScreen 决定如何响应
	ui.home_pressed.connect(_on_home_pressed)

func _on_home_pressed() -> void:
	transition_screen(Game.ScreenType.MAIN_MENU)

func get_bgm_context() -> String:
	return "game"
