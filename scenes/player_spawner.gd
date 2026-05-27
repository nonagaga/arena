class_name PlayerSpawner extends Node3D

signal player_spawned(player_node)
signal player_despawned(player_node)

@export var multiplayer_player : PackedScene
func _ready() -> void:
	Network.player_joined.connect(on_player_joined)
	Network.player_left.connect(on_player_left)
	
	#spawn host
	if multiplayer.is_server():
		on_player_joined()
	
func on_player_joined(id : int = 1):
	var spawned_player = multiplayer_player.instantiate()
	spawned_player.name = str(id)
	call_deferred("add_child", spawned_player)
	player_spawned.emit.call_deferred(spawned_player)

func on_player_left(id : int):
	for player in get_children():
		if player.name == str(id):
			remove_child(player)
			player_despawned.emit(player)
