extends CharacterBody3D
@onready var beta_joints: MeshInstance3D = $Visuals/mixamo_base/Armature/Skeleton3D/Beta_Joints
@onready var beta_surface: MeshInstance3D = $Visuals/mixamo_base/Armature/Skeleton3D/Beta_Surface

func damage():
	var joint_mat : StandardMaterial3D = beta_joints.get_surface_override_material(0)
	var surface_mat : StandardMaterial3D = beta_surface.get_surface_override_material(0)
	
	var default_joint_col = joint_mat.albedo_color
	var default_surface_col = joint_mat.albedo_color
	
	joint_mat.albedo_color = Color.RED
	surface_mat.albedo_color = Color.RED
	
	beta_joints.set_surface_override_material(0, joint_mat)
	beta_surface.set_surface_override_material(0, surface_mat)
	
	var joint_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	var surface_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	joint_tween.tween_property(beta_joints, "surface_material_override/0/albedo_color", default_joint_col, 0.5)
	surface_tween.tween_property(beta_surface, "surface_material_override/0/albedo_color", default_surface_col, 0.5)
