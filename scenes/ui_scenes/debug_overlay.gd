extends Node2D

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		hide()
		await RenderingServer.frame_post_draw
		show()
