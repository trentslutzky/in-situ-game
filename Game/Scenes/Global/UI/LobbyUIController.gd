extends Control

onready var start_layer = $start_layer
onready var client_layer = $client_layer
onready var lobby_layer = $lobby_layer

onready var ip_adress_input = $client_layer/ip_input
onready var port_input = $client_layer/port_input
onready var player_list = $lobby_layer/player_list

var player_icon = load("res://Sprites/icon.png")
	
var layer_state = 1 # jump into join server

# lobby stuff
onready var start_game_button = $lobby_layer/start_game_button
onready var waiting_for_players_text = $lobby_layer/RichTextLabel2
	
func _ready():
	ip_adress_input.text = Network.DEFAULT_IP_ADDRESS
	port_input.text = str(Network.DEFAULT_PORT)
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
func _process(delta):
	match layer_state:
		0:
			start_layer.visible = true
			client_layer.visible = false
			lobby_layer.visible = false
		1:
			start_layer.visible = false
			client_layer.visible = true
			lobby_layer.visible = false
		2:
			start_layer.visible = false
			client_layer.visible = false
			lobby_layer.visible = true
	
	updateLobbyList()
	
	var num_players = 0
	var num_players_ready = 0
	for player in Network.players:
		num_players = num_players + 1
		if Network.players[player]['ready'] == true:
			num_players_ready = num_players_ready + 1
	waiting_for_players_text.visible = not num_players_ready == num_players
	start_game_button.disabled = not num_players_ready == num_players
		

func updateLobbyList():
	var players = Network.players
	player_list.clear()
	var player_index = 0
	for player in players:
		var username = players[player]['username']
		player_list.add_item(username,player_icon,true)
		if(players[player]['ready'] == true):
			player_list.set_item_custom_bg_color(player_index,Color.darkgreen)
			player_list.set_item_text(player_index,username + ' [ready]')
		player_index = player_index + 1
		
func _on_start_as_server_button_pressed():
	Network.StartServer(port_input.text,2)
	layer_state = 2

func _on_start_as_client_pressed():
	layer_state = 1

func _on_join_button_pressed():
	Network.ConnectToServer(ip_adress_input.text,port_input.text)

func _connected_ok():
	layer_state = 2
	
func _on_back_button_pressed():
	if layer_state == 1:
		layer_state = 0

func _on_username_text_changed(new_text):
	Network.my_username = new_text

func _on_ready_up_button_pressed():
	Network.ready_up()

func _on_start_game_button_pressed():
	Network.request_game_load()
