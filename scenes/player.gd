extends CharacterBody3D
@onready var camera_mount: Node3D = $CameraMount
@onready var animation_player: AnimationPlayer = $Visuals/mixamo_base/AnimationPlayer
@onready var visuals: Node3D = $Visuals

@export var WALK_SPEED = 2
@export var RUN_SPEED = 3.5
var speed = 0

const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.1

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-deg_to_rad(event.relative.x) * MOUSE_SENSITIVITY)
		visuals.rotate_y(deg_to_rad(event.relative.x) * MOUSE_SENSITIVITY)
		camera_mount.rotate_x(deg_to_rad(-event.relative.y) * MOUSE_SENSITIVITY)
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if Input.is_action_pressed("sprint"):
			if animation_player.current_animation != "running":
				animation_player.play("running")
				speed = RUN_SPEED
		else:
			if animation_player.current_animation != "walking":
				animation_player.play("walking")
				speed = WALK_SPEED
		var target = visuals.global_basis.looking_at(direction)
		visuals.global_basis = visuals.global_basis.slerp(target, delta * 10)
		#visuals.look_at(position + direction)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
