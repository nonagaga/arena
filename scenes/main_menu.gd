extends Control

@onready var host_button: Button = $VBoxContainer/HostButton
@onready var oid: TextEdit = $VBoxContainer/HBoxContainer/OID
@onready var join_button: Button = $VBoxContainer/HBoxContainer/JoinButton

func _ready() -> void:
	host_button.pressed.connect(on_host_button_pressed)
	join_button.pressed.connect(on_join_button_pressed)
	
func on_host_button_pressed():
	var err = await Network.connect_to_noray()
	if err == OK:
		err = await Network.noray_start_host()
	
func on_join_button_pressed():
	var err = await Network.connect_to_noray()
	if err == OK:
		err = await Network.noray_start_client(oid.text)
