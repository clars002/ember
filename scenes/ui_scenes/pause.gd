extends Node2D

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		await RenderingServer.frame_post_draw # This just buys time to hide UI elements before the viewport gets screenshotted. TODO: Kinda jank.
		toggle_mouse_mode()
		get_tree().paused = !get_tree().paused
		visible = !visible
		
		if get_tree().paused: # i.e. if we have just paused the game
			var mainviewport = get_viewport()
			var screenshot = ImageTexture.create_from_image(mainviewport.get_texture().get_image())
			$PauseMenu/PausedScreenshot.texture = screenshot
			$PauseMenu/PausedScreenshot.show()
			mainviewport.disable_3d = true
			Engine.set_max_fps(DisplayServer.screen_get_refresh_rate()) # TODO: Update when fps cap settings are being implemented
			
			$BgmTimer.start()
		else:
			Engine.set_max_fps(0)
			get_viewport().disable_3d = false
			
			$BgmTimer.stop()
			%PauseBgm.stop()


func _on_settings_menu_settings_changed() -> void:
	pass
	# TODO: Fix this. The timed disable_3d doesn't care if the game is paused.
	#get_viewport().disable_3d = false
	#$PauseMenu/PausedScreenshot.hide()
	#await get_tree().create_timer(10).timeout
	#get_viewport().disable_3d = true
	#$PauseMenu/PausedScreenshot.show()


func _on_bgm_timer_timeout() -> void:
	%PauseBgm.play()

func toggle_mouse_mode() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
