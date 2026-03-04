class_name UI
extends CanvasLayer

@onready var score_label:       Label         = %ScoreLabel
@onready var pause_button:      Button        = %PauseButton
@onready var skill_container:   HBoxContainer = %SkillContainer
@onready var preview_container: HBoxContainer = %PreviewContainer

var _config_data: Array[Dictionary] = []                        

func setup(config_data: Array[Dictionary]) -> void:             
	_config_data = config_data

func on_queue_changed(indices: Array[int]) -> void:
	var slots: Array[Node] = preview_container.get_children()   
	for i in slots.size():
		var queue_pos := i + 1
		if queue_pos >= indices.size():
			break
		var config: Dictionary = _config_data[indices[queue_pos]] 
		var slot: TextureRect = slots[i]
		slot.texture = load(config["texture"])

func update_score(value: int) -> void:
	score_label.text = str(value)
