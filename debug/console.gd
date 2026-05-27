extends CanvasLayer
@onready var text_edit: TextEdit = $VBoxContainer/TextEdit
@onready var line_edit: LineEdit = $VBoxContainer/HBoxContainer/LineEdit
var last_mouse_mode : Input.MouseMode = Input.MOUSE_MODE_VISIBLE

func print(str : String):
	text_edit.text += str + '\n'
	print(str)

func printerr(str : String):
	text_edit.text += "ERROR: " + str + '\n'
	printerr(str)

func _ready() -> void:
	visible = false
	line_edit.text_submitted.connect(_on_text_submitted)
	
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("console"):
		toggle_console()
		await get_tree().process_frame
		line_edit.clear()

func toggle_console():
	# closing console
	if(visible):
		Input.mouse_mode = last_mouse_mode
		line_edit.release_focus()
		visible = false
	# open console
	else:
		last_mouse_mode = Input.mouse_mode
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		line_edit.grab_focus()
		visible = true
	
func _on_text_submitted(command:String):
	var expression := Expression.new()
	var error = expression.parse(command)
	if error != OK:
		Console.printerr(expression.get_error_text())
		return
	
	var result = expression.execute([], self)
	
	if not expression.has_execute_failed():
		if result:
			Console.print(str(result))
	else:
		Console.printerr("Command %s failed to execute." % command)
		
func echo(arguments = null):
	if arguments == null:
		return FAILED
	
	Console.print(arguments)
	
func tp(arguments = null):
	if arguments == null or typeof(arguments) != TYPE_VECTOR3:
		return FAILED
	
	var playerID = str(multiplayer.get_unique_id())
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		player = player as CharacterBody3D
		if player.name == playerID:
			player.global_position = arguments
			return OK

func noclip(arguments = null):
	var id = get_tree().get_multiplayer().get_unique_id()
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		if player.name == str(id):
			if(player.has_method("noclip")):
				player.noclip()
				Console.print("Noclip Toggled on Player: %s" % player.name)
