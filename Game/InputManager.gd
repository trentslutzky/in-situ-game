extends Node

onready var GOManager = get_node('/root/Game/GameObjects')
onready var GameUI = get_node('/root/Game/UI/CanvasLayer/GameUI')
onready var item_list = get_node('/root/Game/UI/CanvasLayer/GameUI/ItemList')

var is_placing = false

func _input(event):
	if(GameUI.mouse_in == false):
		if event.is_action_pressed("mouse_primary"):
			if is_placing:
				GOManager.request_place_object()
		if event.is_action_pressed("mouse_secondary"):
			is_placing = false
			item_list.unselect_all()
