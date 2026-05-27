extends Node

signal player_joined(id)
signal player_left(id)

func connect_signals():
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	
func on_peer_connected(id : int):
	if multiplayer.is_server():
		player_joined.emit(id)

func on_peer_disconnected(id : int):
	if multiplayer.is_server():
		player_left.emit(id)
