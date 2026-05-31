@tool
extends DirectionalLight3D

@export_range(0,1,0.01) var day_progress = 0.0;
@export var day_offset = 0.0
@export var day_speed = 1.0;
@export var intensity_curve : Curve
@export var max_energy = 1.0

func _physics_process(delta: float) -> void:
	update_lighting()
	if(not Engine.is_editor_hint()):
		# ignore if not host
		if(not is_multiplayer_authority()):
			return
		day_progress += PI*2 * delta * day_speed
		if(day_progress >= 1):
			day_progress = 0

func update_lighting():
	rotation.x = PI*2 * (day_progress + day_offset)
	light_energy = intensity_curve.sample(day_progress) * max_energy
