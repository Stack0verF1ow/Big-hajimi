# 挂在游戏场景根节点上，唯一职责：向 GameManager 注册本场景的依赖
extends Node2D

@onready var launcher_manager: LauncherManager = %LauncherManager
@onready var ui:               UI              = %UI

func _ready() -> void:
	# 把场景依赖注入 GameManager，自身不持有任何游戏逻辑
	GameManager.register_scene(ui, launcher_manager, self)
