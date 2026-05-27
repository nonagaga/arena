class_name StateMachine extends Node

@export var states: Dictionary[String, State]
@onready var current_state : State = null

func _ready() -> void:
	var default_state = states["default"]
	if default_state:
		change_states(default_state)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_state:
		current_state._s_process(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state._s_physics_process(delta)

func change_states(new_state_name) -> void:
	current_state._s_exit()
	current_state = states[new_state_name]
	if not current_state:
		push_error("State: % was not found!" % new_state_name)
		return
	current_state._s_enter()
