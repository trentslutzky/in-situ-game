extends Node2D

var direction_rotation = 90
onready var dir_rotate = get_node("Entity/dir_rotate")
onready var graphics = get_node("Entity")

var cursor_color_normal = Color(49,120,102,142)
var cursor_color_invalid = Color(120,49,49,142)

var can_place = true

func _process(delta):
	dir_rotate.rotation_degrees = direction_rotation + 90
	
	graphics.visible = can_place
