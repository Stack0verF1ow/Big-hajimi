class_name InteractableArea
extends Area2D

signal clicked

func _ready() -> void:
	# CollisionObject2D 内置信号，只在点击落在碰撞形状内时触发
	# 前提：Project Settings → Physics → 2D → Physics Picking = true
	input_event.connect(_on_input_event)

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("create"):
		clicked.emit()
		get_viewport().set_input_as_handled()
