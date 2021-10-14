extends Node

var DEFAULT_IP_ADDRESS = ""
var DEFAULT_PORT = 28960
var MAX_PLAYERS = 2

var my_username = ''

var players = {}

var local_unique_id = -1

var synced_placeables = {}

func _ready():
	var ip_addresses = IP.get_local_addresses()
	for ip in ip_addresses:
		if ip.begins_with("192.168.") and not ip.ends_with(".1"):
			DEFAULT_IP_ADDRESS = ip
		else:
			DEFAULT_IP_ADDRESS = '127.0.0.1'
	
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
func ConnectToServer(ip_address=DEFAULT_IP_ADDRESS,port=DEFAULT_PORT):
	print('ConnectToServer: ',ip_address)
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip_address, int(port))
	get_tree().network_peer = peer

func _player_connected(id):
	print('_player_connected: '+str(id))

func _player_disconnected(id):
	print('_player_disconnected: '+str(id))

func _connected_ok():
	print('_connected_ok')
	var player_data = { username = my_username, ready = false }
	local_unique_id = get_tree().get_network_unique_id()
	rpc_id(1,"add_player_data",player_data)
	
func _connected_fail():
	print('_connected_fail')
	pass # Could not even connect to server; abort.

func _server_disconnected():
	pass # Server kicked us; show error and abort.

remote func update_players_list(new_players):
	players = new_players
	print(players)
	
func ready_up():
	rpc_id(1,"player_ready_up")
	
func request_game_load():
	rpc_id(1,"request_game_load")
	
remote func load_game():
	get_tree().change_scene("res://Maps/TestMap.tscn")

func initialize_clinet():
	rpc_id(1,"initialize_client")

remote func start_game():
	get_node("/root/Game").start_game()
	
remote func tick():
	get_node("/root/Game").tick()
