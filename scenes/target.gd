extends CharacterBody3D
@onready var beta_joints: MeshInstance3D = $Visuals/mixamo_base/Armature/Skeleton3D/Beta_Joints
@onready var beta_surface: MeshInstance3D = $Visuals/mixamo_base/Armature/Skeleton3D/Beta_Surface

func damage():
		
	var tweener = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tweener.parallel().tween_property(beta_joints,"surface_material_override/0:shader_parameter/fade", 0.0, 0.5).from(1.0)
	tweener.parallel().tween_property(beta_surface,"surface_material_override/0:shader_parameter/fade", 0.0, 0.5).from(1.0)
