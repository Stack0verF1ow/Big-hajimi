class_name BallQueue

signal queue_changed(indices: Array[int])

const PREVIEW_SIZE   := 3    # 预览数量
const SPAWNABLE_MAX  := 3    # 随机池上限（前几种球可以出现）

var _queue: Array[int] = []

func _init() -> void:
	for i in PREVIEW_SIZE:
		_queue.append(_random_index())

# Game 调用：取出队首，补充队尾，返回本次要生成的 index
func consume() -> int:
	var index := _queue[0]
	_queue.remove_at(0)
	_queue.append(_random_index())
	queue_changed.emit(_queue.duplicate())
	return index

# 初始化时让 UI 拿到初始状态
func peek_all() -> Array[int]:
	return _queue.duplicate()

func _random_index() -> int:
	return randi() % SPAWNABLE_MAX
