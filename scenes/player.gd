extends CharacterBody3D

@onready var camera_mount: Node3D = $CameraMount
@onready var animation_player: AnimationPlayer = $Visuals/mixamo_base/AnimationPlayer
@onready var visuals: Node3D = $Visuals
@onready var camera_3d: Camera3D = $CameraMount/SpringArm3D/Camera3D
@onready var player_input: PlayerInput = $PlayerInput
@onready var camera_input: CameraInput = $CameraInput

@export var WALK_SPEED = 2.0
@export var RUN_SPEED = 3.5
var speed = 0

@export var SHOOT_RANGE = 1000

const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.1

var anim_locked = false

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
  	# Set owner
	player_input.set_multiplayer_authority(name.to_int())
	camera_input.set_multiplayer_authority(name.to_int())
	camera_mount.set_multiplayer_authority(name.to_int())
	change_anim.rpc("XBot_anims/idle")


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
		
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE

func rotate_cam(relative : Vector2) -> void:
	rotate_y(deg_to_rad(-relative.x) * MOUSE_SENSITIVITY)
	visuals.rotate_y(deg_to_rad(relative.x) * MOUSE_SENSITIVITY)

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	if Input.is_action_just_pressed("shoot"):
		var space_state = get_world_3d().direct_space_state
		var mousepos = get_viewport().size/2

		var origin = camera_3d.project_ray_origin(mousepos)
		var end = origin + camera_3d.project_ray_normal(mousepos) * SHOOT_RANGE
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true

		var result = space_state.intersect_ray(query)
		if result:
			var collider = result.get("collider")
			if collider:
				if collider.has_method("damage"):
					collider.damage.rpc()
	
	if is_on_floor():
		anim_locked = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		change_anim.rpc("XBot_anims/run_jump")
		anim_locked = true
	
	if not is_on_floor() and velocity.y < -2:
		change_anim.rpc("XBot_anims/fall")
	
	if direction:
		if Input.is_action_pressed("sprint"):
			if animation_player.current_animation != "XBot_anims/running" and not anim_locked and is_on_floor():
				sprint_cam_tween()
				change_anim.rpc("XBot_anims/running")
				speed = RUN_SPEED
		else:
			if animation_player.current_animation != "XBot_anims/walking" and not anim_locked and is_on_floor():
				change_anim.rpc("XBot_anims/walking")
				speed = WALK_SPEED
				reset_cam_tween()
		var target = Basis.looking_at(direction).orthonormalized()
		visuals.global_basis = visuals.global_basis.orthonormalized().slerp(target, delta * 10)
		#visuals.look_at(position + direction)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		if animation_player.current_animation != "XBot_anims/idle" and not anim_locked and is_on_floor():
			change_anim.rpc("XBot_anims/idle")
			reset_cam_tween()
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func reset_cam_tween():
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera_3d, "fov", 70, 0.5)

func sprint_cam_tween():
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera_3d, "fov", 80, 0.5)
	
func still_jump():
	velocity.y = JUMP_VELOCITY

@rpc("authority","call_local","reliable",0)
func change_anim(anim_name: String):
	animation_player.play(anim_name)
