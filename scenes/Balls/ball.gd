extends RigidBody2D
class_name Ball

var ball_type: int
var score_value: int
var combine_sound: AudioStream
# 预存配置数据
var _pending_data: Dictionary

@onready var sprite = $Sprite2D
@onready var collision = %BallCollisionShape
@onready var sfx_player = $AudioStreamPlayer2D

# 初始化方法，由 Builder 调用
func setup(data: Dictionary):
	_pending_data = data
	# 基础属性（非节点属性）可以立即赋值
	ball_type = data.get("type", 0)
	score_value = data.get("score", 0)

func _ready():
	if _pending_data.is_empty():
		return
		
	# 使用 get(键名, 默认值) 来防止 "Invalid access" 错误
	var tex = _pending_data.get("texture")
	var sc  = _pending_data.get("scale", 1.0) # 如果没有 scale，默认为 1.0
	var rad = _pending_data.get("radius", 50.0)
	
	if tex:
		sprite.texture = tex
		sprite.scale = Vector2(sc, sc)
	
	var shape = CircleShape2D.new()
	shape.radius = rad
	collision.shape = shape
	
	# 音效同理
	var sfx = _pending_data.get("sound")
	if sfx:
		sfx_player.stream = sfx

func _on_body_entered(body):
	# 这里编写合成逻辑：如果碰撞体是同类型水果且 ID 更小（防止重复生成）则合成
	pass
