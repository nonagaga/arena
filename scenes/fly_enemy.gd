extends CharacterBody3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_spawn: PlayerSpawner = $"../player_spawn"
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@export var movement_speed = 5
@onready var movement_target_position = global_position
@onready var csg_combiner_3d: CSGCombiner3D = $visuals/CSGCombiner3D
@onready var blood_particles: CPUParticles3D = $BloodParticles

var player_nodes : Array[Node3D] = []

func _ready() -> void:
	player_spawn.player_spawned.connect(_on_player_spawned)
	player_spawn.player_despawned.connect(_on_player_despawned)
	animation_player.play("fly")
	
func set_movement_target(movement_target: Vector3):
	navigation_agent_3d.set_target_position(movement_target)

func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	movement_target_position = player_nodes[0].global_position
	set_movement_target(movement_target_position)
	
	if navigation_agent_3d.is_navigation_finished():
		return

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent_3d.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	if velocity != Vector3.ZERO:
		look_at(global_position + velocity.normalized())
	move_and_slide()

func _on_player_spawned(spawned_player):
	player_nodes.append(spawned_player)
	

func _on_player_despawned(despawned_player):
	player_nodes.erase(despawned_player)
	
@rpc("any_peer","call_local","reliable")
func damage():
	var tweener = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tweener.parallel().tween_property(csg_combiner_3d,"material_override:shader_parameter/fade", 0.0, 0.5).from(1.0)
	blood_particles.emitting = true
