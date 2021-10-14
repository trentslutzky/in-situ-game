extends Node2D

var synced_game_objects : Dictionary = {}
var synced_game_objects_index = 0

# syncronized game objects:
#	owner_id - network id of owner
#	id - serial index of game object
# 	object_name - unique gameobject name
#	gameobject_id - index of scene in local gameobject array
#	position - global pos of object
#   rotation - rotation of placed object

func restart_game():
	synced_game_objects_index = 0
	synced_game_objects.clear()

remote func request_place_object(object_id,pos,rot):
	var owner_id = get_tree().get_rpc_sender_id()
	var object_name = str(owner_id) + str(synced_game_objects_index)
	var data = {owner_id = owner_id,
				id = synced_game_objects_index,
				object_name = object_name,
				object_id = object_id,
				position = pos,
				rotation = rot
				}
	synced_game_objects[synced_game_objects_index] = data
	print("place object " + str(object_id) + " " + str(pos) + " " + str(rot))
	rpc("remote_place_object",data)
	synced_game_objects_index = synced_game_objects_index + 1

func _ready():
	print('test')
