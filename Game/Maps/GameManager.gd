extends Node2D

onready var local_unique_id = Network.local_unique_id
onready var players = Network.players

func _ready():
	load_players()

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
	
	get_tree().set_pause(true)
	Network.initialize_clinet()
	
func tick():
	pass
	
func start_game():
	get_tree().set_pause(false)
