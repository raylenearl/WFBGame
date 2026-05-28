extends Label

var ball: Node2D
var qb: Node2D
var rb: Node2D
var wr: Node2D

func _ready():
	var main = get_parent()
	
	# Try parent's parent if we're in CanvasLayer
	if not main.has_node("Ball"):
		main = main.get_parent()
	
	ball = main.get_node("Ball")
	qb = main.get_node("Player")
	rb = main.get_node("RunningBack")
	wr = main.get_node("Receiver")
	
	offset_left = 10
	offset_top = 10
	add_theme_font_size_override("font_size", 14)

func _process(delta):
	var info = []
	
	info.append("=== CONTROLS ===")
	info.append("WASD: Move | Shift: Sprint")
	info.append("F: Handoff | Space: Throw")
	info.append("E: Pickup | Q: Drop")
	info.append("")
	
	info.append("=== QB STATS ===")
	if qb:
		info.append("Range: %.0f | Power: %.0f" % [qb.max_throw_distance, qb.throw_power])
		info.append("Accuracy: %.0f%%" % (qb.accuracy * 100))
	
	info.append("")
	info.append("=== WR STATS ===")
	if wr:
		info.append("Catch: %.0f%% | Range: %.0f" % [wr.catch_rating * 100, wr.catch_range])
	
	info.append("")
	if ball:
		info.append("Ball Carrier: %s" % (ball.carried_by.name if ball.carried_by else "LOOSE"))
		info.append("Ball Speed: %.0f" % ball.velocity.length())
		
		if qb and wr:
			var dist = qb.global_position.distance_to(wr.global_position)
			var in_range = "IN RANGE" if dist < qb.max_throw_distance else "OUT OF RANGE"
			info.append("QB-WR Distance: %.0f (%s)" % [dist, in_range])
			
			if ball and not ball.carried_by:
				var ball_to_wr = ball.global_position.distance_to(wr.global_position)
				info.append("Ball to WR: %.0f / catch range: %.0f" % [ball_to_wr, wr.catch_range])
	
	# Show throw status from QB
	if qb and qb.throw_status != "":
		info.append("")
		info.append(">>> THROW <<<")
		info.append(qb.throw_status)
	
	# Show catch status from WR
	if wr and wr.catch_status != "":
		info.append("")
		info.append(">>> CATCH <<<")
		info.append(wr.catch_status)
	
	text = "\n".join(info)
