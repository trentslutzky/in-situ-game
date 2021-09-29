extends Node2D

onready var local_unique_id = Network.local_unique_id
onready var players = Network.players

onready var structures_tilemap = $Structures

var test_placeable = preload("res://Scenes/Placeables/TestPlaceable.tscn")
var placeable_overlay = preload("res://Scenes/Placeables/32_Overlay.tscn")
var overlay = null

export var placeable_lut = {}

func _ready():
	load_players()
	overlay = spawn_object_local(placeable_overlay,Vector2.ZERO,"overlay")
	placeable_lut[1] = {placeable=test_placeable}

func load_players():
	var my_player = preload("res://Scenes/Player/Player.tscn").instance()
	my_player.set_name(str(local_unique_id))
	my_player.set_network_master(local_unique_id)
	my_player.get_node("Username").text = players[local_unique_id]['username']
	my_player.position = Vector2(rand_range(-500,500),rand_range(-300,300))
	get_node("Players").add_child(my_player)
	
	for id in players:
		if(id != local_unique_id):
			var new_player = preload("res://Scenes/Player/Player.tscn").instance()
			new_player.set_name(str(id))
			new_player.set_network_master(id)
			new_player.get_node("Username").text = players[id]['username']
			new_player.position = Vector2(rand_range(-500,500),rand_range(-300,300))
			get_node("Players").add_child(new_player)

func _input(event):
	if event.is_action_pressed("mouse_primary"):
		var click_pos = get_global_mouse_position()
		var map_pos = structures_tilemap.map_to_world(structures_tilemap.world_to_map(click_pos))
		print(str(click_pos) + ' ' + str(map_pos))
		place_placeable(test_placeable,map_pos)

func place_placeable(placeable,pos):
	var placeable_id = 0
	for p in placeable_lut:
		if(placeable_lut[p]['placeable'] == placeable):
			placeable_id = p
	Network.request_placeable(placeable_id,pos)

func spawn_object_local(placeable,pos,node_name):
	var new_placeable = placeable.instance() 
	new_placeable.position = pos
	new_placeable.name = node_name
	get_node("Placeables").add_child(new_placeable)
	return(new_placeable)

func remote_placeable(placeable_info):
	var placeable_id = placeable_info['placeable_id']
	var placeable = placeable_lut[placeable_id]['placeable']
	var pos = placeable_info['pos']
	var owner_id = placeable_info['placeable_owner']
	var ind = placeable_info['placeable_index']
	var node_name = str(owner_id)+str(placeable_id)+str(ind)
	spawn_object_local(placeable,pos,node_name)

func _process(delta):
	var click_pos = get_global_mouse_position()
	var map_pos = structures_tilemap.map_to_world(structures_tilemap.world_to_map(click_pos))
	overlay.global_position = map_pos
