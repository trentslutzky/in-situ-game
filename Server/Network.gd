extends Node

var LOCAL_IP_ADDRESS = ""
var DEFAULT_PORT = 28960
var DEFAULT_MAX_PLAYERS = 4

var players = {}

var synced_placeables = {}
var synced_placeables_index = 0

func _ready():
	var ip_addresses = IP.get_local_addresses()
	for ip in ip_addresses:
		if ip.begins_with("192.168.") and not ip.ends_with(".1"):
			LOCAL_IP_ADDRESS = ip

	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	StartServer()
	
func StartServer(port=DEFAULT_PORT,num_players=DEFAULT_MAX_PLAYERS):
	output_text('Starting server...')
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(int(port), num_players)
	get_tree().network_peer = peer
	output_text('Server started.')

func _player_connected(id):
	output_text('Client ' + str(id) + ' connected')

func _player_disconnected(id):
	output_text('Client ' + str(id) + ' disconnected.')
	players.erase(id)

func output_text(text):
	print(text)

func _on_start_server_pressed():
	StartServer()
	
remote func add_player_data(data):
	output_text('Got request to add player: ' + str(data))
	var id = get_tree().get_rpc_sender_id()
	players[id] = data
	output_text('Added data to players for id ' + str(id))
	rpc("update_players_list",players)
	output_text(data['username']+' joined!')

remote func player_ready_up():
	var id = get_tree().get_rpc_sender_id()
	if(players[id]['ready'] == false):
		players[id]['ready'] = true
		output_text(players[id]['username'] + ' Readied up')
		rpc("update_players_list",players)
		
remote func request_game_start():
	output_text("start game request recieved")
	var num_players = 0
	var num_players_ready = 0
	for player in players:
		num_players = num_players + 1
		if players[player]['ready'] == true:
			num_players_ready = num_players_ready + 1
	if(num_players == num_players_ready):
		output_text("All players ready. Instructing clients to load map.")
		rpc("start_game")
	else:
		output_text("not all players are ready...")

remote func request_placeable(placeable_id,pos):
	var request_id = get_tree().get_rpc_sender_id()
	output_text(str(request_id) + " request placeable " + str(placeable_id))
	var placeable_info = {
		placeable_owner=request_id,
		placeable_id=placeable_id,
		placeable_index=synced_placeables_index,
		pos=pos
	}
	synced_placeables[synced_placeables_index] = placeable_info
	rpc("server_placeable",placeable_info,synced_placeables)
	synced_placeables_index = synced_placeables_index + 1

