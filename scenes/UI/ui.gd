class_name UI
extends CanvasLayer

@onready var score_label:       Label         = %ScoreLabel
@onready var pause_button:      Button        = %PauseButton
@onready var skill_container:   HBoxContainer = %SkillContainer
@onready var preview_container: HBoxContainer = %PreviewContainer

var _config_data: Array[Dictionary] = []

func setup(config_data: Array[Dictionary]) -> void:
	_config_data = config_data

	# GameBus 信号在此统一连接，UI 只需关心显示
	GameBus.score_changed.connect(_on_score_changed)
	GameBus.queue_changed.connect(on_queue_changed)

	# 暂停按钮通过 GameBus 广播，不直接调用 GameManager
	pause_button.pressed.connect(func(): GameBus.pause_requested.emit())

func on_queue_changed(indices: Array[int]) -> void:
	var slots: Array[Node] = preview_container.get_children()
	for i in slots.size():
		var queue_pos := i + 1
		if queue_pos >= indices.size():
			break
		var config: Dictionary = _config_data[indices[queue_pos]]
		var slot: TextureRect = slots[i]
		slot.texture = load(config["texture"])

func show_game_over(final_score: int) -> void:
	# TODO: 显示结算画面，传入最终分数
	print("Game Over UI — 最终得分：", final_score)

func show_pause() -> void:
	# TODO: 显示暂停画面
	pass

func _on_score_changed(value: int) -> void:
	score_label.text = str(value)
