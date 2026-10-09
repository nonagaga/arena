@tool
class_name DaytimeManager
extends Node3D

@export_range(0,1,0.01) var day_progress = 0.0;
@export var day_speed = 0.005;
@export var sun_intensity_curve : Curve
@export var moon_intensity_curve : Curve

@export var sun_gradient : Gradient

@onready var sun: DirectionalLight3D = $Sun
@onready var moon: DirectionalLight3D = $Moon

@export var sun_default_energy = 1.0
@export var moon_default_energy = 0.125
@export var do_daylight_cycle = true

func _ready() -> void:
	day_progress = 0.0

func _physics_process(delta: float) -> void:
	if not do_daylight_cycle:
		return
		
	update_lighting()
	if(not Engine.is_editor_hint()):
		# ignore if not host
		if(not is_multiplayer_authority()):
			return
		day_progress += PI*2 * delta * day_speed
		if(day_progress >= 1):
			day_progress = 0

func update_lighting():
	rotation.x = PI* 2 * day_progress
	sun.light_energy = sun_intensity_curve.sample(day_progress) * sun_default_energy
	moon.light_energy = moon_intensity_curve.sample(day_progress) * moon_default_energy
	sun.visible = (day_progress < 0.6 || day_progress > 0.9)
