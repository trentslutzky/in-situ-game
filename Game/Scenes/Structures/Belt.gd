extends Node2D

onready var GOManager = get_node('/root/Game/GameObjects')
onready var my_path = get_node("Path2D")
onready var parent_point_back = get_node("parent_point_back")
onready var parent_point_left = get_node("parent_point_left")
onready var parent_point_right = get_node("parent_point_right")
onready var child_point = get_node("child_point")
var curve = Curve2D.new()

onready var path_follow = get_node("Path2D/PathFollow2D")

# directional sprites
onready var fwd_sprite = get_node("graphics/fwd_sprite")
onready var left_sprite = get_node("graphics/left_sprite")
onready var right_sprite = get_node("graphics/right_sprite")

var belt_id = ''
var debug_color = Color.whitesmoke

var is_master_belt = true
var is_child_belt = false
var master_belt = null
var parent_belt = null
var child_belt = null

var draw_path = true

var my_direction = 'fwd'

# Called when the node enters the scene tree for the first time.
func _ready():
	my_path.set_curve(self.curve)
	self.belt_id = 'belt' + str(round(global_position.x)) + str(round(global_position.y))
	
	if(GOManager.belts.has(belt_id) == false):
		GOManager.belts[belt_id] = self
		
		self.curve.clear_points()
		self.curve.add_point(Vector2(-16,0))
		self.curve.add_point(Vector2(16,0))
		
		set_dir('fwd')

		update_connections()
	else:
		self.queue_free()
		
func update_connections():
	# get parent belt(s)
	var parent_belt_back_id = 'belt'+str(round(parent_point_back.global_position.x))+str(round(parent_point_back.global_position.y))
	parent_belt_back_id.replace('0','-0')
	var parent_belt_back = GOManager.belts.get(parent_belt_back_id)

	var parent_belt_left_id = 'belt'+str(round(parent_point_left.global_position.x))+str(round(parent_point_left.global_position.y))
	parent_belt_left_id.replace('0','-0')
	parent_belt_left_id.replace('-0','0')

	var parent_belt_left = GOManager.belts.get(parent_belt_left_id)
	
	var parent_belt_right_id = 'belt'+str(round(parent_point_right.global_position.x))+str(round(parent_point_right.global_position.y))
	parent_belt_right_id.replace('0','-0')
	var parent_belt_right = GOManager.belts.get(parent_belt_right_id)
	
	# get child belt
	var child_belt_id = 'belt'+str(round(child_point.global_position.x))+str(round(child_point.global_position.y))
	child_belt_id.replace('0','-0')
	var child_belt = GOManager.belts.get(child_belt_id)
	
	# check for parent belts
	if(parent_belt_back and parent_belt == null and parent_belt_back.child_belt == null):
		var rotation_difference = rotation_degrees - parent_belt_back.rotation_degrees
		if(rotation_difference in [0,90,-90,270,-270]):
			parent_belt = parent_belt_back
			parent_belt.child_belt = self
	if(parent_belt_left and parent_belt == null and parent_belt_left.child_belt == null):
		var rotation_difference = rotation_degrees - parent_belt_left.rotation_degrees
		if(rotation_difference in [90,-90,270]):
			set_dir('left')
			parent_belt = parent_belt_left
			parent_belt.child_belt = self
	if(parent_belt_right and parent_belt == null and parent_belt_right.child_belt == null):
		var rotation_difference = rotation_degrees - parent_belt_right.rotation_degrees
		if(rotation_difference in [90,-270]):
			set_dir('right')
			parent_belt = parent_belt_right
			parent_belt.child_belt = self
	
	if(parent_belt == null):
		is_master_belt = true
		master_belt = self
		debug_color = Color.forestgreen
	else:
		is_child_belt = true
		master_belt = parent_belt.master_belt
		parent_add_points()
	
	if(child_belt):
		if child_belt.is_child_belt == false:
			child_belt.parent_belt = self
			child_belt.master_belt = master_belt
			child_belt.is_master_belt = false
			child_belt.is_child_belt = true
			child_belt.parent_add_points()
		
	update_path()
			
func update_path():
	update()
	
func parent_add_points():
	# transfer points to master belt.
	var point_to_add = position - master_belt.position
	var master_belt_rotation = master_belt.rotation_degrees
	
	if(master_belt_rotation == 270):
		point_to_add = Vector2(point_to_add.y*-1,point_to_add.x)
	if(master_belt_rotation == 90):
		point_to_add = Vector2(point_to_add.y,point_to_add.x*-1)
	if(master_belt_rotation == 180):
		point_to_add = Vector2(point_to_add.x*-1,point_to_add.y*-1)
	
	master_belt.curve.add_point(point_to_add)

	master_belt.update_path()
	# clear my path
	path_follow.queue_free()
			
func set_dir(direction):
	fwd_sprite.visible = direction == 'fwd'
	left_sprite.visible = direction == 'left'
	right_sprite.visible = direction == 'right'
	my_direction = direction
	
	if(direction != 'fwd'):
		self.curve.clear_points()
		if(direction == 'left'):
			self.curve.add_point(Vector2(16,0))
			self.curve.add_point(Vector2(0,0))
			self.curve.add_point(Vector2(0,-16))
		if(direction == 'right'):
			self.curve.add_point(Vector2(16,0))
			self.curve.add_point(Vector2(0,0))
			self.curve.add_point(Vector2(0,16))
			
func _draw():
	if draw_path:
		debug_color.a = 0.6
		draw_rect(Rect2(-16,-16,32,32),debug_color,true)
