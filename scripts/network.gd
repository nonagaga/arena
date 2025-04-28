extends Node

signal spawn_player(id)
signal despawn_player(id)

func connect_signals():
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	
func on_peer_connected(id : int):
	if multiplayer.is_server():
		spawn_player.emit(id)

func on_peer_disconnected(id : int):
	if multiplayer.is_server():
		despawn_player.emit(id)
