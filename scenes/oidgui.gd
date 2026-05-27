extends Control

@onready var oid_label: Label = $HBoxContainer/OIDLabel
@onready var copy_button: Button = $HBoxContainer/CopyButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	copy_button.pressed.connect(_on_copy_presssed)
	if NorayNetwork.host_oid != "":
		oid_label.text = oid_label.text.split(":")[0] + " " + NorayNetwork.host_oid
	else:
		oid_label.text = oid_label.text.split(":")[0] + " " + "No oid found!"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_copy_presssed():
	if NorayNetwork.host_oid != "":
		DisplayServer.clipboard_set(NorayNetwork.host_oid)
