extends Node2D

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _on_button_pressed() -> void:
	get_tree().quit()
