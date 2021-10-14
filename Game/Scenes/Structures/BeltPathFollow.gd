extends PathFollow2D

var belt_speed = 45

func _process(delta):
	set_offset(get_offset() + delta * belt_speed)
