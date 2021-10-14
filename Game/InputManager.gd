extends Node

onready var GOManager = get_node('/root/Game/GameObjects')
onready var GameUI = get_node('/root/Game/UI/CanvasLayer/GameUI')
onready var item_list = get_node('/root/Game/UI/CanvasLayer/GameUI/ItemList')

var is_placing = false

onready var PlacementCursor = get_node('../PlacementCursor')

func _input(event):
	if(GameUI.mouse_in == false):
		if is_placing:
				if event.is_action_pressed("mouse_primary"):
					GOManager.request_place_object()
		if event.is_action_pressed("mouse_secondary"):
			is_placing = false
			item_list.unselect_all()
	
	if event.is_action_released("scroll_up"):
		print('rotate up')
		rotate_object(90)
	if event.is_action_released("scroll_down"):
		print('rotate down')
		rotate_object(-90)
		
func rotate_object(rotation):
	GOManager.place_rotation = GOManager.place_rotation + rotation
	
func _process(delta):
	PlacementCursor.can_place = is_placing
