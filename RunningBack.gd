extends CharacterBody2D

@export var speed: float = 220.0
@export var sprint_multiplier: float = 1.6
@export var pickup_range: float = 70.0

var ball: Node2D
var receiver: Node2D
var qb: Node2D
var is_controllable: bool = false
var has_ball: bool = false

func _ready():
	ball = get_parent().get_node("Ball")
	receiver = get_parent().get_node("Receiver")
	qb = get_parent().get_node("Player")
	
	modulate = Color(0.6, 0.3, 0.3)
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

func _physics_process(delta):
	has_ball = (ball and ball.carried_by == self)
	
	if not is_controllable:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	
	var current_speed = speed
	if Input.is_action_pressed("sprint"):
		current_speed *= sprint_multiplier
	
	velocity = direction * current_speed
	move_and_slide()

func _unhandled_input(event):
	if not is_controllable:
		return
	
	if event.is_action_pressed("pick_up"):
		attempt_pickup()
	
	if event.is_action_pressed("drop"):
		if has_ball:
			ball.drop(velocity * 0.3)
			set_controllable(false)
	
	if event.is_action_pressed("throw"):
		if has_ball and receiver:
			ball.throw_to(receiver.global_position)
			set_controllable(false)
	
	if event.is_action_pressed("handoff"):
		if has_ball and qb:
			var dist = global_position.distance_to(qb.global_position)
			if dist < 100:
				ball.handoff_to(qb)
				set_controllable(false)
				qb.set_controllable(true)

func attempt_pickup():
	if not ball or ball.carried_by:
		return
	
	var dist = global_position.distance_to(ball.global_position)
	if dist < pickup_range:
		if ball.pick_up(self):
			set_controllable(true)

func set_controllable(value: bool):
	is_controllable = value
	modulate = Color(1.0, 0.5, 0.5) if value else Color(0.6, 0.3, 0.3)
