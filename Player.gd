extends CharacterBody2D

# Movement stats
@export var speed: float = 200.0
@export var sprint_multiplier: float = 1.5

# QB Passing Stats
@export var max_throw_distance: float = 900.0
@export var throw_power: float = 900.0
@export var accuracy: float = 0.95
@export var max_inaccuracy: float = 80.0

# Range settings
@export var handoff_range: float = 100.0
@export var pickup_range: float = 70.0

var ball: Node2D
var running_back: Node2D
var receiver: Node2D
var is_controllable: bool = true
var has_ball: bool = false

# Throw feedback
var throw_status: String = ""
var throw_status_timer: float = 0.0

func _ready():
	ball = get_parent().get_node("Ball")
	running_back = get_parent().get_node("RunningBack")
	receiver = get_parent().get_node("Receiver")
	
	modulate = Color(0.5, 0.5, 1.0)
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

func _physics_process(delta):
	# Update throw status timer
	if throw_status_timer > 0:
		throw_status_timer -= delta
		if throw_status_timer <= 0:
			throw_status = ""
	
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
	
	if event.is_action_pressed("handoff"):
		attempt_handoff()
	
	if event.is_action_pressed("throw"):
		attempt_throw()

func attempt_pickup():
	if not ball or ball.carried_by:
		return
	
	var dist = global_position.distance_to(ball.global_position)
	if dist < pickup_range:
		if ball.pick_up(self):
			set_controllable(true)

func attempt_handoff():
	if not has_ball or not running_back:
		return
	
	var dist = global_position.distance_to(running_back.global_position)
	if dist < handoff_range:
		ball.handoff_to(running_back)
		set_controllable(false)
		running_back.set_controllable(true)

func attempt_throw():
	if not has_ball or not receiver:
		throw_status = "Can't throw - no ball or no receiver!"
		throw_status_timer = 2.0
		return
	
	var distance_to_target = global_position.distance_to(receiver.global_position)
	throw_status_timer = 3.0
	
	# Check if target is in range
	if distance_to_target > max_throw_distance:
		throw_status = "OUT OF RANGE! Dist: %.0f / Max: %.0f - Ball falls short" % [distance_to_target, max_throw_distance]
		# Ball falls short
		var direction = (receiver.global_position - global_position).normalized()
		var short_target = global_position + (direction * max_throw_distance)
		throw_with_accuracy(short_target, max_throw_distance, true)
	else:
		throw_status = "Throwing %.0f units to WR" % distance_to_target
		throw_with_accuracy(receiver.global_position, distance_to_target, false)
	
	set_controllable(false)

func throw_with_accuracy(target_pos: Vector2, throw_distance: float, short_throw: bool):
	# Calculate inaccuracy
	var distance_factor = throw_distance / max_throw_distance
	var inaccuracy_amount = (1.0 - accuracy) * max_inaccuracy * (0.5 + distance_factor * 0.5)
	
	# Random offset
	var random_angle = randf() * TAU
	var offset = Vector2(cos(random_angle), sin(random_angle)) * inaccuracy_amount
	
	var final_target = target_pos + offset
	
	# Calculate velocity
	var direction = (final_target - global_position).normalized()
	var throw_velocity = direction * throw_power
	
	ball.drop(throw_velocity)
	
	# Update status with details
	if short_throw:
		throw_status += "\nAccuracy: %.0f%% | Off by: %.0f px" % [accuracy * 100, inaccuracy_amount]
	else:
		throw_status += "\nAccuracy: %.0f%% | Off by: %.0f px" % [accuracy * 100, inaccuracy_amount]

func set_controllable(value: bool):
	is_controllable = value
	modulate = Color(0.5, 0.5, 1.0) if value else Color(0.3, 0.3, 0.6)
