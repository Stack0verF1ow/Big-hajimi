class_name GameScreen
extends Screen

@onready var hajimi_container:  Node2D           = %HajimiContainer
@onready var ui:                UI               = %UI
@onready var interactable_area: InteractableArea = %InteractableArea
@onready var launcher_manager:  LauncherManager  = %LauncherManager

func _ready() -> void:
	ui.setup()

	GameBus.launcher_preview_updated.connect(launcher_manager.show_next_ball)
	GameBus.queue_preview_updated.connect(ui.on_queue_preview_updated)
	GameBus.game_over.connect(ui.show_game_over)

	ui.home_pressed.connect(func(): transition_screen(Game.ScreenType.MAIN_MENU))

	GameManager.register_scene(hajimi_container, launcher_manager, interactable_area)

func _exit_tree() -> void:
	get_tree().paused = false
	if GameBus.launcher_preview_updated.is_connected(launcher_manager.show_next_ball):
		GameBus.launcher_preview_updated.disconnect(launcher_manager.show_next_ball)
	if GameBus.queue_preview_updated.is_connected(ui.on_queue_preview_updated):
		GameBus.queue_preview_updated.disconnect(ui.on_queue_preview_updated)
	if GameBus.game_over.is_connected(ui.show_game_over):
		GameBus.game_over.disconnect(ui.show_game_over)

func get_bgm_context() -> String:
	return "game"
