extends Node2D

var gameobject_data : Array = [
	{
		title="Extractor",
		sprite="res://Sprites/sprites/blocks/drills/mechanical-drill.png",
		scene="res://Scenes/Structures/TestExtractor.tscn",
		size=2,
		rotate=false
	},
	{
		title="Battery",
		sprite="res://Sprites/sprites/blocks/power/battery.png",
		scene="res://Scenes/Placeables/TestPlaceable.tscn",
		size=1,
		rotate=false
	},
	{
		title="Belt",
		sprite="res://Sprites/sprites/blocks/distribution/conveyors/conveyor-0-0.png",
		scene="res://Scenes/Structures/belt.tscn",
		size=1,
		rotate=true
	},
	{
		title="Test Resourse Generator",
		sprite="res://Sprites/sprites/blocks/distribution/conveyors/conveyor-0-0.png",
		scene="res://Scenes/Structures/generatorbelt.tscn",
		size=1,
		rotate=true
	},
]

var belts : Dictionary = {}

var place_rotation = 0

var selected_object = null

onready var structures_tilemap = get_parent().get_node("Structures")

onready var placement_cursor = get_node("../PlacementCursor")

var synced_game_objects : Dictionary = {}
	
func set_selected_object(object_index):
	print(object_index)
	selected_object = object_index
	
func request_place_object():
		var click_pos = get_global_mouse_position() + Vector2(16,16)
		var map_pos = structures_tilemap.map_to_world(structures_tilemap.world_to_map(click_pos))
		# tell server I want to place an item
		rpc_id(1,"request_place_object",selected_object,map_pos,place_rotation)
	
remote func remote_place_object(data):
	synced_game_objects[data['id']] = data
	var object_id = data['object_id']
	var place_position = data['position']
	var object_name = data['object_name']
	var object_rotation = data['rotation']
	# place an item at position
	var object_to_place = load(gameobject_data[object_id]['scene']).instance()
	
	object_to_place.global_position = place_position
	object_to_place.name = object_name
	object_to_place.rotation_degrees = object_rotation
	add_child(object_to_place)
	
func _process(delta):
	var click_pos = get_global_mouse_position() + Vector2(16,16)
	var map_pos = structures_tilemap.map_to_world(structures_tilemap.world_to_map(click_pos))
	placement_cursor.global_position = map_pos
	placement_cursor.direction_rotation = place_rotation
	
	if place_rotation == 360 or place_rotation > 360:
		place_rotation = 0
	if place_rotation == -90 or place_rotation < -90:
		place_rotation = 270
	
	
