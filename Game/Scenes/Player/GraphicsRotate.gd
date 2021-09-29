extends Node2D

puppet var puppet_rotation = 0

func _physics_process(delta):
	if(is_network_master()):
		look_at(get_global_mouse_position())
		rset_unreliable("puppet_rotation",rotation_degrees)
	else:
		rotation_degrees = lerp(rotation_degrees,puppet_rotation,delta*8)
