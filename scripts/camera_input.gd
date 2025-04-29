extends Node
class_name CameraInput
@onready var camera_mount: Node3D = $"../CameraMount"
@onready var camera_3d: Camera3D = $"../CameraMount/SpringArm3D/Camera3D"
@onready var player: CharacterBody3D = $".."

var camera_basis

func _ready():
	NetworkTime.before_tick_loop.connect(_gather)
	
	#if this isn't our cam...
	if not is_multiplayer_authority():
		camera_3d.current = false
		return
	
	camera_3d.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED	

#for use in rollbackable code
func _gather():
	camera_basis = camera_mount.basis
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_mount.rotate_x(deg_to_rad(-event.relative.y) * player.MOUSE_SENSITIVITY)
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, deg_to_rad(-90), deg_to_rad(90))
