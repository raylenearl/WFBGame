extends Node2D

# References
var ball: Node2D
var qb: Node2D
var rb: Node2D
var receiver: Node2D

# Starting positions
var qb_start_pos: Vector2
var rb_start_pos: Vector2
var receiver_start_pos: Vector2
var ball_start_pos: Vector2

# Reset timing
@export var reset_delay: float = 3.0
var reset_timer: float = 0.0
var is_resetting: bool = false

# Down tracking
var current_down: int = 1
var max_downs: int = 4

# Status display
var status_label: Label

func _ready():
	await get_tree().create_timer(0.3).timeout
	
	ball = find_node_safely("Ball")
	qb = find_node_safely("Player")
	rb = find_node_safely("RunningBack")
	receiver = find_node_safely("Receiver")
	
	create_status_label()
	
	if not ball or not qb or not rb or not receiver:
		update_status("ERROR: Nodes not found!")
		return
	
	qb_start_pos = qb.global_position
	rb_start_pos = rb.global_position
	receiver_start_pos = receiver.global_position
	ball_start_pos = ball.global_position
	
	update_status("GameManager Ready!\nDown: 1/4")

func find_node_safely(node_name: String) -> Node:
	var node = get_node_or_null(node_name)
	if node:
		return node
	
	if get_parent():
		node = get_parent().get_node_or_null(node_name)
		if node:
			return node
	
	return find_in_tree(get_tree().root, node_name)

func find_in_tree(node: Node, target_name: String) -> Node:
	if node.name == target_name:
		return node
	for child in node.get_children():
		var result = find_in_tree(child, target_name)
		if result:
			return result
	return null

func create_status_label():
	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color.YELLOW)
	
	status_label.anchor_left = 1.0
	status_label.anchor_right = 1.0
	status_label.offset_left = -250
	status_label.offset_top = 10
	status_label.offset_right = -10
	
	var canvas = get_node_or_null("CanvasLayer")
	if not canvas:
		canvas = get_parent().get_node_or_null("CanvasLayer")
	
	if canvas:
		canvas.add_child(status_label)
	else:
		add_child(status_label)

func update_status(text: String):
	if status_label:
		status_label.text = text

func _process(delta):
	if not ball or not qb:
		return
	
	var status = "Down: %d/%d\n" % [current_down, max_downs]
	
	# Ball is being carried - everything is fine
	if ball.carried_by:
		reset_timer = 0.0
		status += "Carrier: " + ball.carried_by.name
		if is_resetting:
			status += "\nRESETTING..."
	# Ball is loose AND moving (in flight) - don't start timer yet
	elif ball.velocity.length() > 50:
		reset_timer = 0.0
		status += "BALL IN FLIGHT\nSpeed: %.0f" % ball.velocity.length()
	# Ball is loose and stopped - start reset timer
	elif not is_resetting:
		reset_timer += delta
		var time_left = reset_delay - reset_timer
		status += "BALL LOOSE!\nReset in: %.1fs" % time_left
		
		# Only auto-switch control when ball has stopped
		auto_switch_control()
		
		if reset_timer >= reset_delay:
			reset_play()
	
	update_status(status)

func auto_switch_control():
	# Don't switch control if anyone is already controllable
	if qb.is_controllable or rb.is_controllable or receiver.is_controllable:
		return
	
	# Find nearest player to ball
	var nearest = qb
	var nearest_dist = qb.global_position.distance_to(ball.global_position)
	
	var rb_dist = rb.global_position.distance_to(ball.global_position)
	if rb_dist < nearest_dist:
		nearest = rb
		nearest_dist = rb_dist
	
	var wr_dist = receiver.global_position.distance_to(ball.global_position)
	if wr_dist < nearest_dist:
		nearest = receiver
	
	# Only give control to the nearest player
	if nearest == qb:
		qb.set_controllable(true)
	elif nearest == rb:
		rb.set_controllable(true)
	else:
		receiver.set_controllable(true)

func reset_play():
	if is_resetting:
		return
	
	is_resetting = true
	
	current_down += 1
	if current_down > max_downs:
		current_down = 1
	
	qb.global_position = qb_start_pos
	rb.global_position = rb_start_pos
	receiver.global_position = receiver_start_pos
	ball.global_position = ball_start_pos
	
	qb.velocity = Vector2.ZERO
	rb.velocity = Vector2.ZERO
	receiver.velocity = Vector2.ZERO
	ball.velocity = Vector2.ZERO
	
	ball.pick_up(qb)
	qb.set_controllable(true)
	rb.set_controllable(false)
	receiver.set_controllable(false)
	
	await get_tree().create_timer(0.5).timeout
	is_resetting = false
	reset_timer = 0.0
