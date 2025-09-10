extends Area3D
@onready var ouch: AudioStreamPlayer3D = $"../sounds/ouch"
@onready var cat: CharacterBody3D = $".."

@rpc("any_peer","call_local","reliable")
func damage():
	cat.damage()
