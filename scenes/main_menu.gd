extends Control

@onready var host_button: Button = $VBoxContainer/HostButton
@onready var oid: TextEdit = $VBoxContainer/HBoxContainer/OID
@onready var join_button: Button = $VBoxContainer/HBoxContainer/JoinButton
@export var game_scene : PackedScene
@onready var connection_label: RichTextLabel = $ConnectionLabel

var connected = null

func _ready() -> void:
	host_button.pressed.connect(on_host_button_pressed)
	join_button.pressed.connect(on_join_button_pressed)
	connected = await NorayNetwork.connect_to_noray()
	if connected == OK:
		connection_label.text = "Connected to Noray!"
	else:
		connection_label.text = "Not connected to Noray!"
	
func on_host_button_pressed():
	NorayNetwork.isHost = true
	if connected == OK:
		await NorayNetwork.noray_start_host()
	get_tree().change_scene_to_packed(game_scene)
	
func on_join_button_pressed():
	NorayNetwork.isHost = false
	var err = await NorayNetwork.connect_to_noray()
	if err == OK:
		err = await NorayNetwork.noray_start_client(oid.text)
		await multiplayer.connected_to_server
		get_tree().change_scene_to_packed(game_scene)
