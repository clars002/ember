extends Label

func _process(delta: float) -> void:
	set_text("%d fps" % Engine.get_frames_per_second())
