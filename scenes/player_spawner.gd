extends Node3D

@export var multiplayer_player : PackedScene

func _ready() -> void:
	Network.spawn_player.connect(on_spawn_player)
	Network.despawn_player.connect(on_despawn_player)
	
func on_spawn_player(id : int):
	var spawned_player = multiplayer_player.instantiate()
	spawned_player.name = id
	add_child(spawned_player)

func on_despawn_player(id : int):
	for player in get_children():
		if player.name == str(id):
			remove_child(player)
