extends CharacterBody2D

var carried_by = null
@export var carry_offset: Vector2 = Vector2(30, 0)
@export var throw_speed: float = 600.0

# Cooldown to prevent immediate re-pickup by thrower
var pickup_cooldown: float = 0.0
var thrower = null  # Who threw it (can't catch own throw immediately)

func _ready():
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	await get_tree().create_timer(0.2).timeout
	var qb = get_parent().get_node("Player")
	if qb:
		pick_up(qb)

func _physics_process(delta):
	if pickup_cooldown > 0:
		pickup_cooldown -= delta
		if pickup_cooldown <= 0:
			thrower = null  # Clear thrower after cooldown
	
	if carried_by:
		if not is_instance_valid(carried_by):
			carried_by = null
			velocity = Vector2.ZERO
			return
		
		global_position = carried_by.global_position + carry_offset
		velocity = Vector2.ZERO
		modulate = Color(1, 1, 0.5)
	else:
		modulate = Color.WHITE
		
		velocity *= 0.92
		
		if velocity.length() < 5:
			velocity = Vector2.ZERO
		
		if velocity.length() > 0:
			move_and_slide()

func pick_up(character) -> bool:
	# Can't pick up if same person who just threw it (during cooldown)
	if pickup_cooldown > 0 and character == thrower:
		print("Cannot pick up - cooldown active for thrower")
		return false
	
	carried_by = character
	velocity = Vector2.ZERO
	pickup_cooldown = 0.0
	thrower = null
	print("Ball PICKED UP by: ", character.name)
	return true

func drop(drop_velocity: Vector2 = Vector2.ZERO):
	# Remember who dropped/threw it
	thrower = carried_by
	carried_by = null
	velocity = drop_velocity
	pickup_cooldown = 0.3  # Only thrower can't pick up

func handoff_to(new_carrier):
	carried_by = new_carrier
	velocity = Vector2.ZERO

func throw_to(target_position: Vector2):
	var direction = (target_position - global_position).normalized()
	drop(direction * throw_speed)
