extends Camera2D

var ball: Node2D

func _ready():
	ball = get_parent().get_node("Ball")
	
	enabled = true
	make_current()
	zoom = Vector2(0.8, 0.8)
	
	if ball:
		global_position = ball.global_position
	
	print("Camera ready - following ball")

func _process(delta):
	if ball:
		global_position = ball.global_position
