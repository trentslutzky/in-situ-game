extends Node

func exit_game():
	get_tree().network_peer = null
	get_tree().quit()
