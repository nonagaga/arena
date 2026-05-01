extends CanvasLayer
@onready var text_edit: TextEdit = $VBoxContainer/TextEdit
@onready var line_edit: LineEdit = $VBoxContainer/HBoxContainer/LineEdit
var last_mouse_mode : Input.MouseMode = Input.MOUSE_MODE_VISIBLE

func print(str : String):
	text_edit.text += str + '\n'
	print(str)

func _ready() -> void:
	visible = false
	
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
	
