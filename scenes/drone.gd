extends RigidBody3D

@export_category("PID Gains")
@export var Kp = 2.0
@export var Kd = 0.0
@export var Ki = 0.0

@export_category("Numerical Settings")
@export var points_to_diff = 1
@export var points_to_integrate = 5

@export_category("Everything else")
@export var desired_height = 5

@onready var thruster_fl: Node3D = $"Thruster FL"
@onready var thruster_fr: Node3D = $"Thruster FR"
@onready var thruster_rl: Node3D = $"Thruster RL"
@onready var thruster_rr: Node3D = $"Thruster RR"
var thrusters = []
var prev_errors = []

func _ready() -> void:
	thrusters = [thruster_fl, thruster_fr, thruster_rl, thruster_rr]
	for i in range(len(thrusters)):
		var array = []
		for j in range(max(points_to_diff, points_to_integrate)):
			array.append(0)
		prev_errors.append(array)
	
func _physics_process(delta: float) -> void:
	for i in range(len(thrusters)):
		var thruster = thrusters[i]
		pid_control_thruster(thruster, i, delta)
	
func pid_control_thruster(thruster: Node3D, thruster_idx: int, delta: float) -> void:
	var raycast = thruster.get_node("RayCast3D") as RayCast3D
	var height = 0
	
	if raycast.is_colliding():
		height = thruster.global_position.distance_to(raycast.get_collision_point())
	
	if height > 0:
		var err = desired_height - height
		var d_err = (err - prev_errors[thruster_idx][len(prev_errors)-1])/delta
		
		var i_err = 0
		for val in prev_errors[thruster_idx]:
			i_err += val
		i_err *= delta
		
		var control = Kp * err + Kd * err + Ki * err
		apply_force(Vector3.UP * control, thruster.global_position - global_position)
		prev_errors[thruster_idx].push_front(err)
		prev_errors[thruster_idx].pop_back()
