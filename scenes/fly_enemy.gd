extends CharacterBody3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_spawn: PlayerSpawner = $"../player_spawn"

@export var SPEED = 100

var player_nodes : Array[Node3D] = []

func _ready() -> void:
	player_spawn.player_spawned.connect(_on_player_spawned)
	player_spawn.player_despawned.connect(_on_player_despawned)
	animation_player.play("fly")

func _physics_process(delta: float) -> void:
	if player_nodes:
		look_at(player_nodes[0].global_position)
		velocity = -basis.z * SPEED * delta
		
	else:
		velocity = Vector3.ZERO
	move_and_slide()

func _on_player_spawned(spawned_player):
	player_nodes.append(spawned_player)

func _on_player_despawned(despawned_player):
	player_nodes.erase(despawned_player)
