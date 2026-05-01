extends Label
var original_text = ""

func _ready() -> void:
	original_text = text
	
func _process(delta: float) -> void:
	text = original_text + str(int(1/delta))
