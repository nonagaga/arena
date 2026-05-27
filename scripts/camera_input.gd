extends Node
class_name CameraInput
@onready var camera_mount: Node3D = $"../CameraMount"
@onready var spring_arm_3d: SpringArm3D = $"../CameraMount/SpringArm3D"
@onready var camera_3d: Camera3D = $"../CameraMount/SpringArm3D/Camera3D"
@onready var player: CharacterBody3D = $".."
@export var min_spring_length = 1.0
@export var max_spring_length = 6.0
@export var zoom_per_scroll = 0.5

func _ready():
	#if this isn't our cam...
	if not is_multiplayer_authority():
		camera_3d.current = false
		return
	
	camera_3d.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED	
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_mount.rotate_x(deg_to_rad(-event.relative.y) * player.MOUSE_SENSITIVITY)
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		player.rotate_cam(event.relative)
	if event is InputEventMouseButton:
		spring_arm_3d.spring_length += Input.get_axis("camera_zoom_in", "camera_zoom_out") * zoom_per_scroll
		spring_arm_3d.spring_length = clampf(spring_arm_3d.spring_length, min_spring_length, max_spring_length)
