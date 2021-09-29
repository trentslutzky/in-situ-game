extends KinematicBody2D

var MOVE_ACCELERATION = 3500
var MAX_SPEED = 400

var motion = Vector2()

onready var tween = $Tween

# netcode movement
puppet var puppet_position = Vector2(0,0) setget puppet_position_set
puppet var puppet_velocity = Vector2()

func _physics_process(delta):
	if is_network_master():
		var axis = get_input_axis()
		
		if axis == Vector2.ZERO:
			apply_friction(MOVE_ACCELERATION * delta)
		else:
			apply_movement(axis * MOVE_ACCELERATION * delta)
			
		motion = move_and_slide(motion)
		
		# send my position to the server/other clients
		rset_unreliable("puppet_position", global_position)
		rset_unreliable("puppet_velocity", motion)
	else:
		if not tween.is_active():
			move_and_slide(puppet_velocity)

func get_input_axis():
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	axis.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return axis.normalized()
		
func apply_friction(amount):
	if motion.length() > amount:
		motion -= motion.normalized() * amount/2
	else:
		motion = Vector2.ZERO
	
func apply_movement(acceleration):
	motion += acceleration
	motion = motion.clamped(MAX_SPEED)
	
func puppet_position_set(new_value):
	puppet_position = new_value
	tween.interpolate_property(self,"global_position",global_position,puppet_position,0.1)
	tween.start()
