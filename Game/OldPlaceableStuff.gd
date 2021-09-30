extends Node

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
	get_node("Gameobjects").add_child(new_placeable)
	return(new_placeable)

func remote_placeable(placeable_info):
	var placeable_id = placeable_info['placeable_id']
	var placeable = placeable_lut[placeable_id]['placeable']
	var pos = placeable_info['pos']
	var owner_id = placeable_info['placeable_owner']
	var ind = placeable_info['placeable_index']
	var node_name = str(owner_id)+str(placeable_id)+str(ind)
	spawn_object_local(placeable,pos,node_name)
