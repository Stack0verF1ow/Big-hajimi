class_name BallQueue
extends RefCounted

signal queue_changed(indices: Array[int])

const QUEUE_SIZE    := 3   # 预览队列长度
const SPAWNABLE_MAX := 3   # 只有前 3 号可随机生成（index 0~2）

var _queue: Array[int] = []

func _init() -> void:
	for i in QUEUE_SIZE:
		_queue.append(_random_index())

func consume() -> int:
	var index := _queue[0]
	_queue.remove_at(0)
	_queue.append(_random_index())
	queue_changed.emit(_queue.duplicate())
	return index

func peek_all() -> Array[int]:
	return _queue.duplicate()

func _random_index() -> int:
	return randi() % SPAWNABLE_MAX   # 始终只产生 0、1、2
