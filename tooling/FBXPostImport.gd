@tool # Needed so it runs in editor.
extends EditorScenePostImport
var textures_folder = "../../textures"
# This sample changes all node names.
# Called right after the scene is imported and gets the root node.
func _post_import(scene):
	print(scene)
	# Change all node names to "modified_[oldnodename]"
	iterate(scene)
	return scene # Remember to return the imported scene

func search_for_texture(prefix):
	var regex = RegEx.new()
	# Pattern matches files with specific prefix before the extension
	regex.compile("(?i)" + prefix + "\\.(png|jpg|jpeg|bmp|webp|svg)$")
	var dir_path = get_source_file().path_join(textures_folder).simplify_path()
	print(dir_path)
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if regex.search(file_name):
					return ResourceLoader.load(dir.get_current_dir().path_join( file_name))
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path.")

func iterate(node):
	if node != null:
		# write logic here
		if node is MeshInstance3D:
			for surface in node.mesh.get_surface_count():
				var material = node.mesh.surface_get_material(surface)
				print("Searching for material: %s" % material.resource_name)
				var texture = search_for_texture(material.resource_name)
				if texture:
					material.set('albedo_texture', texture)
					material.set('transparency', BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR)
					print("Succesfully found material: %s" % material.resource_name)
				
		for child in node.get_children():
			iterate(child)
