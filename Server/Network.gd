extends Node

var LOCAL_IP_ADDRESS = ""
var DEFAULT_PORT = 28960
var DEFAULT_MAX_PLAYERS = 4

var players = {}
var players_initialized = {}

var game_start = false

onready var timer = Timer.new()

func _ready():
	add_child(timer)
	timer.start()
	var ip_addresses = IP.get_local_addresses()
	for ip in ip_addresses:
		if ip.begins_with("192.168.") and not ip.ends_with(".1"):
			LOCAL_IP_ADDRESS = ip

	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	StartServer()
	timer.connect("timeout",self,"_server_tick")
	
func _server_tick():
	if game_start:
		rpc("tick")
	
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
	players_initialized[id] = false
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
		
remote func request_game_load():
	output_text("game load request recieved")
	var num_players = 0
	var num_players_ready = 0
	for player in players:
		num_players = num_players + 1
		if players[player]['ready'] == true:
			num_players_ready = num_players_ready + 1
	if(num_players == num_players_ready):
		output_text("All players ready. Instructing clients to load map.")
		rpc("load_game")
	else:
		output_text("not all players are ready...")
	
remote func initialize_client():
	var request_id = get_tree().get_rpc_sender_id()
	players_initialized[request_id] = true
	var num_players = players_initialized.size()
	var num_players_initialized = 0
	for player in players_initialized:
		if players_initialized[player] == true:
			num_players_initialized = num_players_initialized + 1
	if(num_players == num_players_initialized):
		# start game
		rpc("start_game")
		game_start = true
	
	
		
