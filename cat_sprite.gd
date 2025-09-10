@tool
extends Sprite3D

# how large the resultant image will be in meters
@export var image_size = 1.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture_changed.connect(_on_property_list_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_property_list_changed():
	var texture_size = texture.get_size().x
	pixel_size = image_size/texture_size
