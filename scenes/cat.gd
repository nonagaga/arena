extends CharacterBody3D

@export var player_spawner : PlayerSpawner
@export var movement_speed: float = 1.0
@onready var meow_timer: Timer = $sounds/meow_timer

@onready var cat_sprite: Sprite3D = $visuals/cat_sprite
@onready var meow: AudioStreamPlayer3D = $sounds/meow
@onready var angry: AudioStreamPlayer3D = $sounds/angry
@onready var ouch: AudioStreamPlayer3D = $sounds/ouch
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var target : Node3D = null
@onready var movement_target_position = global_position

const OHMYGOS = preload("res://images/Ohmygos.png")
const EVIL_CAT = preload("res://images/Evil_Cat.png")
const EL_GATO = preload("res://images/El_Gato.png")

@rpc("any_peer","call_local","reliable")
func damage():
	cat_sprite.texture = OHMYGOS
	animation_player.stop(true)
	animation_player.play("hurt",0)

func _setup_audio_callbacks():
	reset_meow_timer()
	
	ouch.finished.connect(func():
		cat_sprite.texture = EL_GATO
		)
	meow_timer.timeout.connect(func():
		if ouch.playing:
			reset_meow_timer()
		else:
			meow.play()
		)

func reset_meow_timer():
	meow_timer.start(randf_range(1,5))

func _ready() -> void:
	player_spawner.player_spawned.connect(_on_player_spawned)
	player_spawner.player_despawned.connect(_on_player_despawned)
	_setup_audio_callbacks()

func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	look_at(get_viewport().get_camera_3d().global_position, Vector3.UP)
	rotation.x = 0
	rotation.z = 0
	
	movement_target_position = target.global_position
	navigation_agent_3d.set_target_position(movement_target_position)
	
	if navigation_agent_3d.is_navigation_finished():
		return

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent_3d.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	move_and_slide()

func _on_player_spawned(spawned_player):
	target = spawned_player

func _on_player_despawned(despawned_player):
	if target == despawned_player:
		target = null
