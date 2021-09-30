extends Node2D

export var preload_game_objects : Array = []
export var preload_game_object_names : Array = []

var selected_object = null

onready var structures_tilemap = get_parent().get_node("Structures")

var synced_game_objects : Dictionary = {}
	
func set_selected_object(object_index):
	print(object_index)
	selected_object = object_index
	
func request_place_object():
		var click_pos = get_global_mouse_position()
		var map_pos = structures_tilemap.map_to_world(structures_tilemap.world_to_map(click_pos))
		# tell server I want to place an item
		rpc_id(1,"request_place_object",selected_object,map_pos)
	
remote func remote_place_object(data):
	print('Place object',data['object_id'])
	synced_game_objects[data['id']] = data
	var object_id = data['object_id']
	var place_position = data['position']
	var object_name = data['object_name']
	# place an item at position
	var object_to_place = preload_game_objects[object_id].instance()
	object_to_place.global_position = place_position
	object_to_place.name = object_name
	add_child(object_to_place)
	
	
	
