extends RigidBody3D

@export var kick_strength = 50.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not is_multiplayer_authority():
		freeze = true
		
	body_entered.connect(_on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		var player_vec = body.global_position - global_position
		apply_central_force(-player_vec * kick_strength * body.velocity.length())		
