class_name Game
extends Node2D

@onready var hajimi_container: StaticBody2D = %HajimiContainer
@onready var spawn_point: Marker2D = %SpawnPoint

var director: BallDirector

func _ready():
	var builder = BallBuilder.new()
	
	director = BallDirector.new(builder)
	
	var data = DataLoader.load_ball_config("res://data/ball_config.json")
	director.load_data(data)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("create"):
		spawn_ball()


func spawn_ball():
	# 随机生成前三种水果中的一种
	var random_index = randi() % 3 
	var ball = director.create_ball_by_index(random_index)
	
	if ball:
		add_child(ball)
		ball.position = get_global_mouse_position()
