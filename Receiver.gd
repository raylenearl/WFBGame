extends CharacterBody2D

# Movement stats
@export var speed: float = 240.0
@export var sprint_multiplier: float = 1.7

# Receiver Stats
@export var catch_range: float = 80.0
@export var catch_rating: float = 0.80
@export var pickup_range: float = 70.0

var ball: Node2D
var is_controllable: bool = false
var has_ball: bool = false
var attempted_catch: bool = false
var catch_status: String = ""
var catch_status_timer: float = 0.0

func _ready():
	ball = get_parent().get_node("Ball")
	
	modulate = Color(0.3, 0.6, 0.3)
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

func _physics_process(delta):
	# Update catch status timer
	if catch_status_timer > 0:
		catch_status_timer -= delta
		if catch_status_timer <= 0:
			catch_status = ""
	
	# Auto-catch attempt if ball is in flight nearby
	if ball and not ball.carried_by:
		var dist = global_position.distance_to(ball.global_position)
		var ball_speed = ball.velocity.length()
		
		if ball_speed > 30 and dist < catch_range and not attempted_catch:
			attempt_catch()
	
	# Reset catch attempt when ball is far or carried
	if ball:
		var dist = global_position.distance_to(ball.global_position)
		if ball.carried_by or dist > catch_range * 2:
			attempted_catch = false
	
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

func attempt_catch():
	attempted_catch = true
	
	var catch_roll = randf()
	var success = catch_roll <= catch_rating
	
	catch_status_timer = 2.0
	
	if success:
		# Force pickup - bypass cooldown for catches
		ball.carried_by = self
		ball.velocity = Vector2.ZERO
		ball.pickup_cooldown = 0.0
		ball.thrower = null
		
		set_controllable(true)
		catch_status = "CAUGHT! (%.0f%% chance, rolled %.0f%%)" % [catch_rating * 100, catch_roll * 100]
		print("Receiver CAUGHT the ball!")
	else:
		catch_status = "DROPPED! (%.0f%% chance, rolled %.0f%%)" % [catch_rating * 100, catch_roll * 100]
		# Deflect the ball
		ball.velocity *= 0.3
		var random_angle = randf() * TAU
		ball.velocity += Vector2(cos(random_angle), sin(random_angle)) * 100
		print("Receiver DROPPED the ball!")

func _unhandled_input(event):
	if not is_controllable:
		return
	
	if event.is_action_pressed("pick_up"):
		attempt_pickup()
	
	if event.is_action_pressed("drop"):
		if has_ball:
			ball.drop(velocity * 0.3)
			set_controllable(false)

func attempt_pickup():
	if not ball or ball.carried_by:
		return
	
	var dist = global_position.distance_to(ball.global_position)
	if dist < pickup_range:
		# Force pickup for receiver (bypass cooldown)
		ball.carried_by = self
		ball.velocity = Vector2.ZERO
		ball.pickup_cooldown = 0.0
		ball.thrower = null
		set_controllable(true)

func set_controllable(value: bool):
	is_controllable = value
	modulate = Color(0.5, 1.0, 0.5) if value else Color(0.3, 0.6, 0.3)
