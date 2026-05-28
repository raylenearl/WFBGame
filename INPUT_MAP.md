# Input Map Configuration for WFBGame
# 
# This file documents all input actions used by the game scripts.
# Add these actions to your Godot project via Project > Project Settings > Input Map
#
# Action Name | Key Binding | Purpose
# ============|=============|=================================
# move_left   | A           | Move character left
# move_right  | D           | Move character right
# move_up     | W           | Move character up
# move_down   | S           | Move character down
# sprint      | Shift       | Sprint (1.5-1.7x speed multiplier)
# pick_up     | E           | Pick up the ball
# drop        | Q           | Drop/fumble the ball
# handoff     | F           | Hand off ball to nearby player
# throw       | Space       | Throw ball to target receiver

# Godot Input Map Setup (programmatic)
# Run this in _ready() of Main.gd if actions don't exist:

#func _setup_input_map():
#	# Movement
#	if not InputMap.has_action("move_left"):
#		InputMap.add_action("move_left")
#		InputMap.action_add_event("move_left", InputEventKey.new())
#		InputMap.action_set_deadzone("move_left", 0.5)
#	
#	if not InputMap.has_action("move_right"):
#		InputMap.add_action("move_right")
#	
#	if not InputMap.has_action("move_up"):
#		InputMap.add_action("move_up")
#	
#	if not InputMap.has_action("move_down"):
#		InputMap.add_action("move_down")
#	
#	# Actions
#	if not InputMap.has_action("sprint"):
#		InputMap.add_action("sprint")
#	
#	if not InputMap.has_action("pick_up"):
#		InputMap.add_action("pick_up")
#	
#	if not InputMap.has_action("drop"):
#		InputMap.add_action("drop")
#	
#	if not InputMap.has_action("handoff"):
#		InputMap.add_action("handoff")
#	
#	if not InputMap.has_action("throw"):
#		InputMap.add_action("throw")
